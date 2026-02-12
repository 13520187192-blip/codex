using System.Text.Json;

namespace BreakReminderWindows;

internal sealed class ReminderSettings
{
    public int WorkDurationMinutes { get; set; } = 30;
    public int BreakDurationMinutes { get; set; } = 5;
    public int SnoozeMinutes { get; set; } = 5;
    public bool EnableBalloonNotification { get; set; } = true;
    public bool EnablePopupDialog { get; set; } = true;
    public bool EnableSound { get; set; } = true;

    private static string SettingsPath
    {
        get
        {
            var basePath = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "BreakReminderWindows");
            Directory.CreateDirectory(basePath);
            return Path.Combine(basePath, "settings.json");
        }
    }

    public ReminderSettings Sanitize()
    {
        return new ReminderSettings
        {
            WorkDurationMinutes = Clamp(WorkDurationMinutes, 15, 120),
            BreakDurationMinutes = Clamp(BreakDurationMinutes, 3, 30),
            SnoozeMinutes = Clamp(SnoozeMinutes, 1, 30),
            EnableBalloonNotification = EnableBalloonNotification,
            EnablePopupDialog = EnablePopupDialog,
            EnableSound = EnableSound
        };
    }

    public static ReminderSettings Load()
    {
        try
        {
            if (!File.Exists(SettingsPath))
            {
                return new ReminderSettings();
            }

            var raw = File.ReadAllText(SettingsPath);
            var parsed = JsonSerializer.Deserialize<ReminderSettings>(raw);
            return (parsed ?? new ReminderSettings()).Sanitize();
        }
        catch
        {
            return new ReminderSettings();
        }
    }

    public void Save()
    {
        var safe = Sanitize();
        var json = JsonSerializer.Serialize(safe, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(SettingsPath, json);
    }

    private static int Clamp(int value, int min, int max)
    {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }
}
