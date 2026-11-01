using System;
using System.Runtime.InteropServices;
using System.Windows;

namespace JuwishPro.Client
{
    public partial class App : Application
    {
        [DllImport("shell32.dll", SetLastError = true)]
        private static extern int SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string AppID);

        protected override void OnStartup(StartupEventArgs e)
        {
            try
            {
                // Explicitly set AppUserModelID so Windows Taskbar pins and identifies this app independently
                SetCurrentProcessExplicitAppUserModelID("TechDaddyHub.JuwishPro.Client");
            }
            catch { }

            base.OnStartup(e);

            AppDomain.CurrentDomain.UnhandledException += (s, args) =>
            {
                var ex = args.ExceptionObject as Exception;
                MessageBox.Show(
                    $"Startup Error: {ex?.Message}\n\nPlease ensure your Windows is updated and Microsoft Edge WebView2 is installed.",
                    "JuwishPro",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
            };

            DispatcherUnhandledException += (s, args) =>
            {
                MessageBox.Show(
                    $"Application Error: {args.Exception.Message}",
                    "JuwishPro",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                args.Handled = true;
            };
        }
    }
}
