namespace BreakReminderWindows;

internal sealed class SettingsForm : Form
{
    private readonly NumericUpDown _workNumeric;
    private readonly NumericUpDown _breakNumeric;
    private readonly NumericUpDown _snoozeNumeric;
    private readonly CheckBox _balloonCheckbox;
    private readonly CheckBox _popupCheckbox;
    private readonly CheckBox _soundCheckbox;

    public ReminderSettings? Result { get; private set; }

    public SettingsForm(ReminderSettings current)
    {
        Text = "休息提醒设置";
        Width = 420;
        Height = 320;
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;

        var workLabel = new Label { Text = "专注时长（分钟）", Left = 24, Top = 24, Width = 130 };
        _workNumeric = new NumericUpDown { Left = 180, Top = 22, Width = 180, Minimum = 15, Maximum = 120, Value = current.WorkDurationMinutes };

        var breakLabel = new Label { Text = "休息时长（分钟）", Left = 24, Top = 64, Width = 130 };
        _breakNumeric = new NumericUpDown { Left = 180, Top = 62, Width = 180, Minimum = 3, Maximum = 30, Value = current.BreakDurationMinutes };

        var snoozeLabel = new Label { Text = "稍后提醒（分钟）", Left = 24, Top = 104, Width = 130 };
        _snoozeNumeric = new NumericUpDown { Left = 180, Top = 102, Width = 180, Minimum = 1, Maximum = 30, Value = current.SnoozeMinutes };

        _balloonCheckbox = new CheckBox { Text = "系统托盘气泡提醒", Left = 24, Top = 146, Width = 180, Checked = current.EnableBalloonNotification };
        _popupCheckbox = new CheckBox { Text = "强提醒弹窗", Left = 24, Top = 174, Width = 180, Checked = current.EnablePopupDialog };
        _soundCheckbox = new CheckBox { Text = "提示音", Left = 24, Top = 202, Width = 180, Checked = current.EnableSound };

        var saveButton = new Button { Text = "保存", Left = 192, Top = 240, Width = 80, Height = 32 };
        var cancelButton = new Button { Text = "取消", Left = 280, Top = 240, Width = 80, Height = 32 };

        saveButton.Click += (_, _) =>
        {
            Result = new ReminderSettings
            {
                WorkDurationMinutes = (int)_workNumeric.Value,
                BreakDurationMinutes = (int)_breakNumeric.Value,
                SnoozeMinutes = (int)_snoozeNumeric.Value,
                EnableBalloonNotification = _balloonCheckbox.Checked,
                EnablePopupDialog = _popupCheckbox.Checked,
                EnableSound = _soundCheckbox.Checked
            }.Sanitize();

            DialogResult = DialogResult.OK;
            Close();
        };

        cancelButton.Click += (_, _) =>
        {
            DialogResult = DialogResult.Cancel;
            Close();
        };

        Controls.Add(workLabel);
        Controls.Add(_workNumeric);
        Controls.Add(breakLabel);
        Controls.Add(_breakNumeric);
        Controls.Add(snoozeLabel);
        Controls.Add(_snoozeNumeric);
        Controls.Add(_balloonCheckbox);
        Controls.Add(_popupCheckbox);
        Controls.Add(_soundCheckbox);
        Controls.Add(saveButton);
        Controls.Add(cancelButton);
    }
}
