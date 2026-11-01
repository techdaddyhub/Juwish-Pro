using System;
using System.Windows;

namespace JuwishPro.Admin
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            AppDomain.CurrentDomain.UnhandledException += (s, args) =>
            {
                var ex = args.ExceptionObject as Exception;
                MessageBox.Show(
                    $"Startup Error: {ex?.Message}\n\nPlease ensure your Windows is updated and Microsoft Edge WebView2 is installed.",
                    "JuwishPro Admin",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
            };

            DispatcherUnhandledException += (s, args) =>
            {
                MessageBox.Show(
                    $"Application Error: {args.Exception.Message}",
                    "JuwishPro Admin",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                args.Handled = true;
            };
        }
    }
}
