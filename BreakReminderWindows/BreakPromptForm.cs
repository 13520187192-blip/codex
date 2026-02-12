namespace BreakReminderWindows;

internal sealed class BreakPromptForm : Form
{
    public event Action? StartBreakClicked;
    public event Action? SnoozeClicked;
    public event Action? SkipClicked;

    public BreakPromptForm()
    {
        Text = "休息提醒";
        Width = 420;
        Height = 220;
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;
        TopMost = true;

        var title = new Label
        {
            Text = "该休息了",
            Font = new Font(Font.FontFamily, 18, FontStyle.Bold),
            AutoSize = true,
            Location = new Point(150, 24)
        };

        var subtitle = new Label
        {
            Text = "离开屏幕几分钟，活动一下身体。",
            AutoSize = true,
            Location = new Point(110, 68)
        };

        var startBreakButton = new Button
        {
            Text = "开始休息",
            Width = 100,
            Height = 34,
            Location = new Point(40, 120)
        };
        startBreakButton.Click += (_, _) =>
        {
            StartBreakClicked?.Invoke();
            Close();
        };

        var snoozeButton = new Button
        {
            Text = "稍后提醒",
            Width = 100,
            Height = 34,
            Location = new Point(155, 120)
        };
        snoozeButton.Click += (_, _) =>
        {
            SnoozeClicked?.Invoke();
            Close();
        };

        var skipButton = new Button
        {
            Text = "跳过本次",
            Width = 100,
            Height = 34,
            Location = new Point(270, 120)
        };
        skipButton.Click += (_, _) =>
        {
            SkipClicked?.Invoke();
            Close();
        };

        Controls.Add(title);
        Controls.Add(subtitle);
        Controls.Add(startBreakButton);
        Controls.Add(snoozeButton);
        Controls.Add(skipButton);
    }
}
