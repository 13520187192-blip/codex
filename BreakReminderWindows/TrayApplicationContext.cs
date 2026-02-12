using System.Media;

namespace BreakReminderWindows;

internal sealed class TrayApplicationContext : ApplicationContext
{
    private readonly NotifyIcon _notifyIcon;
    private readonly System.Windows.Forms.Timer _timer;

    private ReminderSettings _settings;
    private ReminderState _state = ReminderState.Idle;

    private DateTime? _focusEndAt;
    private DateTime? _breakEndAt;
    private DateTime? _snoozeUntil;

    private (ReminderState state, TimeSpan remaining)? _pausedSnapshot;

    public TrayApplicationContext()
    {
        _settings = ReminderSettings.Load();

        var menu = new ContextMenuStrip();
        menu.Items.Add("开始专注", null, (_, _) => StartOrResume());
        menu.Items.Add("暂停", null, (_, _) => Pause());
        menu.Items.Add("开始休息", null, (_, _) => BeginBreakNow());
        menu.Items.Add("稍后提醒", null, (_, _) => Snooze());
        menu.Items.Add("跳过本次", null, (_, _) => SkipCurrentBreak());
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("设置", null, (_, _) => OpenSettings());
        menu.Items.Add("退出", null, (_, _) => ExitThread());

        _notifyIcon = new NotifyIcon
        {
            Icon = SystemIcons.Information,
            Text = "休息提醒：空闲",
            ContextMenuStrip = menu,
            Visible = true
        };

        _notifyIcon.DoubleClick += (_, _) => StartOrResume();

        _timer = new System.Windows.Forms.Timer { Interval = 1000 };
        _timer.Tick += (_, _) => OnTick();
        _timer.Start();

        UpdateTooltip();
    }

    private void StartOrResume()
    {
        if (_state == ReminderState.Paused && _pausedSnapshot.HasValue)
        {
            var snap = _pausedSnapshot.Value;
            switch (snap.state)
            {
                case ReminderState.Focusing:
                    _focusEndAt = DateTime.Now.Add(snap.remaining);
                    _state = ReminderState.Focusing;
                    break;
                case ReminderState.OnBreak:
                    _breakEndAt = DateTime.Now.Add(snap.remaining);
                    _state = ReminderState.OnBreak;
                    break;
                case ReminderState.Snoozed:
                    _snoozeUntil = DateTime.Now.Add(snap.remaining);
                    _state = ReminderState.Snoozed;
                    break;
                case ReminderState.BreakDue:
                    _state = ReminderState.BreakDue;
                    break;
                default:
                    _state = ReminderState.Idle;
                    break;
            }
            _pausedSnapshot = null;
        }
        else
        {
            _focusEndAt = DateTime.Now.AddMinutes(_settings.WorkDurationMinutes);
            _breakEndAt = null;
            _snoozeUntil = null;
            _state = ReminderState.Focusing;
        }

        UpdateTooltip();
    }

    private void Pause()
    {
        switch (_state)
        {
            case ReminderState.Focusing when _focusEndAt.HasValue:
                _pausedSnapshot = (ReminderState.Focusing, Remaining(_focusEndAt.Value));
                break;
            case ReminderState.OnBreak when _breakEndAt.HasValue:
                _pausedSnapshot = (ReminderState.OnBreak, Remaining(_breakEndAt.Value));
                break;
            case ReminderState.Snoozed when _snoozeUntil.HasValue:
                _pausedSnapshot = (ReminderState.Snoozed, Remaining(_snoozeUntil.Value));
                break;
            case ReminderState.BreakDue:
                _pausedSnapshot = (ReminderState.BreakDue, TimeSpan.Zero);
                break;
            default:
                return;
        }

        _state = ReminderState.Paused;
        UpdateTooltip();
    }

    private void BeginBreakNow()
    {
        if (_state is ReminderState.BreakDue or ReminderState.Snoozed)
        {
            _breakEndAt = DateTime.Now.AddMinutes(_settings.BreakDurationMinutes);
            _state = ReminderState.OnBreak;
            HandleBreakStarted();
            UpdateTooltip();
        }
    }

    private void Snooze()
    {
        if (_state == ReminderState.BreakDue)
        {
            _snoozeUntil = DateTime.Now.AddMinutes(_settings.SnoozeMinutes);
            _state = ReminderState.Snoozed;
            UpdateTooltip();
        }
    }

    private void SkipCurrentBreak()
    {
        if (_state is ReminderState.BreakDue or ReminderState.OnBreak or ReminderState.Snoozed)
        {
            _focusEndAt = DateTime.Now.AddMinutes(_settings.WorkDurationMinutes);
            _breakEndAt = null;
            _snoozeUntil = null;
            _state = ReminderState.Focusing;
            UpdateTooltip();
        }
    }

    private void OpenSettings()
    {
        using var form = new SettingsForm(_settings);
        if (form.ShowDialog() == DialogResult.OK && form.Result is not null)
        {
            _settings = form.Result;
            _settings.Save();
        }
    }

    private void OnTick()
    {
        var previous = _state;

        switch (_state)
        {
            case ReminderState.Focusing when _focusEndAt.HasValue && DateTime.Now >= _focusEndAt.Value:
                _state = ReminderState.BreakDue;
                break;
            case ReminderState.OnBreak when _breakEndAt.HasValue && DateTime.Now >= _breakEndAt.Value:
                _focusEndAt = DateTime.Now.AddMinutes(_settings.WorkDurationMinutes);
                _state = ReminderState.Focusing;
                break;
            case ReminderState.Snoozed when _snoozeUntil.HasValue && DateTime.Now >= _snoozeUntil.Value:
                _state = ReminderState.BreakDue;
                break;
        }

        if (_state != previous)
        {
            if (_state == ReminderState.BreakDue)
            {
                HandleBreakDue();
            }
            else if (_state == ReminderState.OnBreak)
            {
                HandleBreakStarted();
            }
        }

        UpdateTooltip();
    }

    private void HandleBreakDue()
    {
        if (_settings.EnableSound)
        {
            SystemSounds.Exclamation.Play();
        }

        if (_settings.EnableBalloonNotification)
        {
            _notifyIcon.BalloonTipTitle = "休息提醒";
            _notifyIcon.BalloonTipText = "你已经专注一段时间了，该休息一下。";
            _notifyIcon.ShowBalloonTip(4000);
        }

        if (_settings.EnablePopupDialog)
        {
            using var popup = new BreakPromptForm();
            popup.StartBreakClicked += BeginBreakNow;
            popup.SnoozeClicked += Snooze;
            popup.SkipClicked += SkipCurrentBreak;
            popup.ShowDialog();
        }
    }

    private void HandleBreakStarted()
    {
        if (_settings.EnableBalloonNotification)
        {
            _notifyIcon.BalloonTipTitle = "开始休息";
            _notifyIcon.BalloonTipText = $"本次休息建议时长 {_settings.BreakDurationMinutes} 分钟。";
            _notifyIcon.ShowBalloonTip(3000);
        }
    }

    private TimeSpan Remaining(DateTime endAt)
    {
        var remaining = endAt - DateTime.Now;
        return remaining < TimeSpan.Zero ? TimeSpan.Zero : remaining;
    }

    private void UpdateTooltip()
    {
        var text = _state switch
        {
            ReminderState.Idle => "休息提醒：空闲",
            ReminderState.Paused => "休息提醒：已暂停",
            ReminderState.BreakDue => "休息提醒：该休息了",
            ReminderState.Focusing when _focusEndAt.HasValue => $"专注中 {FormatRemaining(_focusEndAt.Value)}",
            ReminderState.OnBreak when _breakEndAt.HasValue => $"休息中 {FormatRemaining(_breakEndAt.Value)}",
            ReminderState.Snoozed when _snoozeUntil.HasValue => $"稍后提醒 {FormatRemaining(_snoozeUntil.Value)}",
            _ => "休息提醒"
        };

        _notifyIcon.Text = text.Length > 63 ? text[..63] : text;
    }

    private static string FormatRemaining(DateTime until)
    {
        var rem = until - DateTime.Now;
        if (rem < TimeSpan.Zero)
        {
            rem = TimeSpan.Zero;
        }

        return $"{(int)rem.TotalMinutes:00}:{rem.Seconds:00}";
    }

    protected override void ExitThreadCore()
    {
        _notifyIcon.Visible = false;
        _notifyIcon.Dispose();
        _timer.Stop();
        _timer.Dispose();
        base.ExitThreadCore();
    }
}
