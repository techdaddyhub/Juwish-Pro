using System;
using System.Diagnostics;
using System.IO;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace JuwishPro.Client
{
    public partial class MainWindow : Window
    {
        private const string TargetUrl = "https://2026.dmillers.org";
        private const string WebView2InstallerUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703";
        private bool _isMissingWebView2 = false;

        public MainWindow()
        {
            InitializeComponent();
            Loaded += MainWindow_Loaded;
        }

        private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            await InitializeBrowserAsync();
        }

        private async System.Threading.Tasks.Task InitializeBrowserAsync()
        {
            try
            {
                _isMissingWebView2 = false;

                // Dedicated persistent cache in user's LocalAppData to avoid permissions issues anywhere on disk
                string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string userDataFolder = Path.Combine(localAppData, "JuwishPro", "Client", "WebView2");
                Directory.CreateDirectory(userDataFolder);

                var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder);
                await webView.EnsureCoreWebView2Async(env);

                var settings = webView.CoreWebView2.Settings;
                settings.AreDefaultContextMenusEnabled = false;
                settings.IsStatusBarEnabled = false;
                settings.AreDevToolsEnabled = false;
                settings.AreBrowserAcceleratorKeysEnabled = false;
                settings.IsBuiltInErrorPageEnabled = false;
                settings.UserAgent = settings.UserAgent + " JuwishProWindows/1.0.0 (Native Desktop; x64)";

                webView.CoreWebView2.NavigationStarting += CoreWebView2_NavigationStarting;
                webView.CoreWebView2.NavigationCompleted += CoreWebView2_NavigationCompleted;

                webView.Source = new Uri(TargetUrl);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"WebView2 initialization failed: {ex}");
                ShowInitializationError(ex);
            }
        }

        private void ShowInitializationError(Exception ex)
        {
            string exName = ex.GetType().Name;
            string exMsg = ex.Message;

            if (exName.Contains("WebView2RuntimeNotFound") || 
                exName.Contains("DllNotFound") || 
                exMsg.IndexOf("WebView2", StringComparison.OrdinalIgnoreCase) >= 0 ||
                exMsg.IndexOf("runtime", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                _isMissingWebView2 = true;
                txtErrorTitle.Text = "Microsoft Edge WebView2 Required";
                txtErrorMessage.Text = "JuwishPro requires the Microsoft Edge WebView2 runtime component to run on Windows. Click below to download and install it directly from Microsoft.";
                btnAction.Content = "Install WebView2 Runtime";
            }
            else
            {
                _isMissingWebView2 = false;
                txtErrorTitle.Text = "Initialization Error";
                txtErrorMessage.Text = $"Unable to start application engine: {ex.Message}";
                btnAction.Content = "Retry";
            }

            errorPanel.Visibility = Visibility.Visible;
        }

        private void CoreWebView2_NavigationStarting(object? sender, CoreWebView2NavigationStartingEventArgs e)
        {
            if (Uri.TryCreate(e.Uri, UriKind.Absolute, out var uri))
            {
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

                if (!IsAllowedAppHost(uri.Host))
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

        private static bool IsAllowedAppHost(string? host)
        {
            if (string.IsNullOrEmpty(host)) return false;
            host = host.ToLowerInvariant();
            return host == "2026.dmillers.org" || host.EndsWith(".dmillers.org")
                || host == "accounts.google.com" || host.EndsWith(".google.com")
                || host.EndsWith(".googleusercontent.com") || host.EndsWith(".gstatic.com")
                || host == "accounts.youtube.com" || host == "oauth2.googleapis.com"
                || host == "apis.google.com"
                || host == "github.com" || host.EndsWith(".github.com")
                || host == "appleid.apple.com"
                || host == "facebook.com" || host.EndsWith(".facebook.com")
                || host == "twitter.com" || host.EndsWith(".twitter.com")
                || host == "x.com" || host.EndsWith(".x.com");
        }

        private void CoreWebView2_NavigationCompleted(object? sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            if (!e.IsSuccess)
            {
                _isMissingWebView2 = false;
                txtErrorTitle.Text = "Connection Offline";
                txtErrorMessage.Text = "Network connection is currently unavailable. Please check your internet settings.";
                btnAction.Content = "Retry Connection";
                errorPanel.Visibility = Visibility.Visible;
            }
            else
            {
                errorPanel.Visibility = Visibility.Collapsed;
            }
        }

        private async void OnActionButtonClick(object sender, RoutedEventArgs e)
        {
            if (_isMissingWebView2)
            {
                try
                {
                    Process.Start(new ProcessStartInfo(WebView2InstallerUrl) { UseShellExecute = true });
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Could not open browser: {ex.Message}", "JuwishPro", MessageBoxButton.OK, MessageBoxImage.Warning);
                }
            }
            else
            {
                errorPanel.Visibility = Visibility.Collapsed;
                if (webView.CoreWebView2 != null)
                {
                    webView.CoreWebView2.Reload();
                }
                else
                {
                    await InitializeBrowserAsync();
                }
            }
        }
    }
}
