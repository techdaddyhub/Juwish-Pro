using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media.Imaging;
using Microsoft.Web.WebView2.Core;

namespace JuwishPro.Admin
{
    public partial class MainWindow : Window
    {
        private const string TargetUrl = "https://2026.dmillers.org/admin/dashboard";
        private const string WebView2InstallerUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703";
        private bool _isMissingWebView2 = false;

        private const uint WM_SETICON = 0x0080;
        private static readonly IntPtr ICON_SMALL = (IntPtr)0;
        private static readonly IntPtr ICON_BIG = (IntPtr)1;

        private const uint IMAGE_ICON = 1;
        private const uint LR_SHARED = 0x8000;

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr GetModuleHandle(string? lpModuleName);

        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern IntPtr LoadImage(IntPtr hinst, IntPtr lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr LoadIcon(IntPtr hInstance, IntPtr lpIconName);

        public MainWindow()
        {
            InitializeComponent();
            Loaded += MainWindow_Loaded;
        }

        protected override void OnSourceInitialized(EventArgs e)
        {
            base.OnSourceInitialized(e);
            SetupTaskbarAndWindowIcon();
        }

        private void SetupTaskbarAndWindowIcon()
        {
            try
            {
                // Ensure WPF Window Icon is set via pack URI
                var iconUri = new Uri("pack://application:,,,/app.ico", UriKind.RelativeOrAbsolute);
                this.Icon = BitmapFrame.Create(iconUri);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Icon] WPF Icon binding notice: {ex.Message}");
            }

            try
            {
                // Explicitly send WM_SETICON messages to Win32 HWND so Windows Taskbar and Alt+Tab always display the icon
                var hwnd = new WindowInteropHelper(this).Handle;
                if (hwnd != IntPtr.Zero)
                {
                    IntPtr hModule = GetModuleHandle(null);

                    // Load 32x32 icon for Taskbar & Alt+Tab switcher (ICON_BIG)
                    IntPtr hBigIcon = LoadImage(hModule, (IntPtr)1, IMAGE_ICON, 32, 32, LR_SHARED);
                    if (hBigIcon == IntPtr.Zero)
                    {
                        hBigIcon = LoadIcon(hModule, (IntPtr)1);
                    }

                    // Load 16x16 icon for Window Titlebar (ICON_SMALL)
                    IntPtr hSmallIcon = LoadImage(hModule, (IntPtr)1, IMAGE_ICON, 16, 16, LR_SHARED);
                    if (hSmallIcon == IntPtr.Zero)
                    {
                        hSmallIcon = LoadIcon(hModule, (IntPtr)1);
                    }

                    if (hBigIcon != IntPtr.Zero)
                    {
                        SendMessage(hwnd, WM_SETICON, ICON_BIG, hBigIcon);
                    }
                    if (hSmallIcon != IntPtr.Zero)
                    {
                        SendMessage(hwnd, WM_SETICON, ICON_SMALL, hSmallIcon);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Icon] Win32 WM_SETICON notice: {ex.Message}");
            }
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
                string userDataFolder = Path.Combine(localAppData, "JuwishPro", "Admin", "WebView2");
                Directory.CreateDirectory(userDataFolder);

                var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder);
                await webView.EnsureCoreWebView2Async(env);

                var settings = webView.CoreWebView2.Settings;
                settings.AreDefaultContextMenusEnabled = false;
                settings.IsStatusBarEnabled = false;
                settings.AreDevToolsEnabled = false;
                settings.AreBrowserAcceleratorKeysEnabled = false;
                settings.IsBuiltInErrorPageEnabled = false;
                settings.UserAgent = settings.UserAgent + " JuwishProAdminWindows/1.0.0 (Native Desktop Admin; x64)";

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
                txtErrorMessage.Text = "JuwishPro Admin requires the Microsoft Edge WebView2 runtime component to run on Windows. Click below to download and install it directly from Microsoft.";
                btnAction.Content = "Install WebView2 Runtime";
            }
            else
            {
                _isMissingWebView2 = false;
                txtErrorTitle.Text = "Initialization Error";
                txtErrorMessage.Text = $"Unable to start admin console engine: {ex.Message}";
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

                // Dedicated Admin Panel lock: prevent admin app from falling back to client homepage
                if (uri.Host.Equals("2026.dmillers.org", StringComparison.OrdinalIgnoreCase))
                {
                    var path = uri.AbsolutePath;
                    if (string.IsNullOrEmpty(path) || path == "/" || path == "/home" || path.StartsWith("/user", StringComparison.OrdinalIgnoreCase))
                    {
                        e.Cancel = true;
                        webView.Source = new Uri(TargetUrl);
                        return;
                    }
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
                    MessageBox.Show($"Could not open browser: {ex.Message}", "JuwishPro Admin", MessageBoxButton.OK, MessageBoxImage.Warning);
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
