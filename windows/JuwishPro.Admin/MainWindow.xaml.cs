using System;
using System.Diagnostics;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace JuwishPro.Admin
{
    public partial class MainWindow : Window
    {
        private const string TargetUrl = "https://2026.dmillers.org/admin";

        public MainWindow()
        {
            InitializeComponent();
            Loaded += MainWindow_Loaded;
        }

        private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                var env = await CoreWebView2Environment.CreateAsync();
                await webView.EnsureCoreWebView2Async(env);

                var settings = webView.CoreWebView2.Settings;
                // Lockdown admin app: hide devtools, context menu, status bar, and accelerators
                settings.AreDefaultContextMenusEnabled = false;
                settings.IsStatusBarEnabled = false;
                settings.AreDevToolsEnabled = false;
                settings.AreBrowserAcceleratorKeysEnabled = false;
                settings.IsBuiltInErrorPageEnabled = false;
                settings.UserAgent = settings.UserAgent + " JuwishProAdminWindows/1.0.0 (Native Desktop Admin)";

                webView.CoreWebView2.NavigationStarting += CoreWebView2_NavigationStarting;
                webView.CoreWebView2.NavigationCompleted += CoreWebView2_NavigationCompleted;

                webView.Source = new Uri(TargetUrl);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"WebView2 initialization failed: {ex.Message}");
                errorPanel.Visibility = Visibility.Visible;
            }
        }

        private void CoreWebView2_NavigationStarting(object? sender, CoreWebView2NavigationStartingEventArgs e)
        {
            if (Uri.TryCreate(e.Uri, UriKind.Absolute, out var uri))
            {
                // External communications (whatsapp, mailto, tel)
                if (uri.Scheme != "http" && uri.Scheme != "https")
                {
                    try
                    {
                        Process.Start(new ProcessStartInfo(e.Uri) { UseShellExecute = true });
                    }
                    catch { }
                    e.Cancel = true;
                    return;
                }

                // If navigating outside JuwishPro platform
                if (!uri.Host.Equals("2026.dmillers.org", StringComparison.OrdinalIgnoreCase) &&
                    !uri.Host.EndsWith(".dmillers.org", StringComparison.OrdinalIgnoreCase))
                {
                    try
                    {
                        Process.Start(new ProcessStartInfo(e.Uri) { UseShellExecute = true });
                    }
                    catch { }
                    e.Cancel = true;
                }
            }
        }

        private void CoreWebView2_NavigationCompleted(object? sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            if (!e.IsSuccess)
            {
                errorPanel.Visibility = Visibility.Visible;
            }
            else
            {
                errorPanel.Visibility = Visibility.Collapsed;
            }
        }

        private void OnRetryClick(object sender, RoutedEventArgs e)
        {
            errorPanel.Visibility = Visibility.Collapsed;
            webView.CoreWebView2?.Reload();
        }
    }
}

