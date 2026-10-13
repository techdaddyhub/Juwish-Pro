package org.dmillers.juwishpro;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.URLUtil;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

public class MainActivity extends AppCompatActivity {

    public static final String TARGET_URL = "https://2026.dmillers.org";

    private WebView webView;
    private SwipeRefreshLayout swipeRefreshLayout;
    private ProgressBar progressBar;
    private LinearLayout errorLayout;
    private TextView errorDescription;
    private Button btnRetry;

    private ValueCallback<Uri[]> filePathCallback;
    private long lastBackPressTime = 0;

    private final ActivityResultLauncher<Intent> fileChooserLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (filePathCallback != null) {
                    Uri[] results = null;
                    if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                        String dataString = result.getData().getDataString();
                        if (dataString != null) {
                            results = new Uri[]{Uri.parse(dataString)};
                        } else if (result.getData().getClipData() != null) {
                            int count = result.getData().getClipData().getItemCount();
                            results = new Uri[count];
                            for (int i = 0; i < count; i++) {
                                results[i] = result.getData().getClipData().getItemAt(i).getUri();
                            }
                        }
                    }
                    filePathCallback.onReceiveValue(results);
                    filePathCallback = null;
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initViews();
        setupWebView();
        setupSwipeRefresh();
        setupBackNavigation();

        loadTargetUrl();
    }

    private void initViews() {
        webView = findViewById(R.id.webView);
        swipeRefreshLayout = findViewById(R.id.swipeRefreshLayout);
        progressBar = findViewById(R.id.progressBar);
        errorLayout = findViewById(R.id.errorLayout);
        errorDescription = findViewById(R.id.errorDescription);
        btnRetry = findViewById(R.id.btnRetry);

        btnRetry.setOnClickListener(v -> {
            errorLayout.setVisibility(View.GONE);
            webView.setVisibility(View.VISIBLE);
            loadTargetUrl();
        });
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void setupWebView() {
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort = true;
        settings.setBuiltInZoomControls(false);
        settings.setDisplayZoomControls(false);
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);
        settings.setMediaPlaybackRequiresUserGesture(false);

        // Append JuwishPro Mobile App identifier for server attribution
        String defaultUa = settings.getUserAgentString();
        settings.setUserAgentString(defaultUa + " JuwishProMobile/1.0.0 (Android Native)");

        // Enable Cookies & Third-party cookies for Laravel Sanctum sessions
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.setAcceptThirdPartyCookies(webView, true);

        // File download handling (statements, receipts, invoices)
        webView.setDownloadListener((url, userAgent, contentDisposition, mimetype, contentLength) -> {
            try {
                DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
                request.setMimeType(mimetype);
                request.addRequestHeader("User-Agent", userAgent);
                request.setDescription("Downloading file from JuwishPro...");
                request.setTitle(URLUtil.guessFileName(url, contentDisposition, mimetype));
                request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
                request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS,
                        URLUtil.guessFileName(url, contentDisposition, mimetype));

                DownloadManager dm = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
                if (dm != null) {
                    dm.enqueue(request);
                    Toast.makeText(MainActivity.this, "Download started...", Toast.LENGTH_SHORT).show();
                }
            } catch (Exception e) {
                // Fallback to external browser
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                startActivity(intent);
            }
        });

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Uri uri = request.getUrl();
                String scheme = uri.getScheme();
                String host = uri.getHost();

                // Open external communication apps natively (WhatsApp, Telegram, Tel, Mailto)
                if (scheme != null && !scheme.equals("http") && !scheme.equals("https")) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                        startActivity(intent);
                    } catch (ActivityNotFoundException ignored) {
                        Toast.makeText(MainActivity.this, "Application not found to handle request", Toast.LENGTH_SHORT).show();
                    }
                    return true;
                }

                // If navigating within JuwishPro platform
                if (host != null && (host.equals("2026.dmillers.org") || host.endsWith(".dmillers.org"))) {
                    return false;
                }

                // External links (Social media, external documentation)
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                    startActivity(intent);
                    return true;
                } catch (Exception ignored) {
                    return false;
                }
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                progressBar.setVisibility(View.VISIBLE);
                errorLayout.setVisibility(View.GONE);
                webView.setVisibility(View.VISIBLE);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                progressBar.setVisibility(View.GONE);
                swipeRefreshLayout.setRefreshing(false);
            }

            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
                if (request.isForMainFrame()) {
                    progressBar.setVisibility(View.GONE);
                    swipeRefreshLayout.setRefreshing(false);
                    webView.setVisibility(View.GONE);
                    errorLayout.setVisibility(View.VISIBLE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        errorDescription.setText(error.getDescription());
                    }
                }
            }
        });

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                super.onProgressChanged(view, newProgress);
                progressBar.setProgress(newProgress);
                if (newProgress >= 100) {
                    progressBar.setVisibility(View.GONE);
                    swipeRefreshLayout.setRefreshing(false);
                } else {
                    progressBar.setVisibility(View.VISIBLE);
                }
            }

            // File Chooser for KYC document uploads, camera, and gallery photos
            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback,
                                              FileChooserParams fileChooserParams) {
                if (MainActivity.this.filePathCallback != null) {
                    MainActivity.this.filePathCallback.onReceiveValue(null);
                }
                MainActivity.this.filePathCallback = filePathCallback;

                Intent intent;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    intent = fileChooserParams.createIntent();
                } else {
                    intent = new Intent(Intent.ACTION_GET_CONTENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("*/*");
                }

                try {
                    fileChooserLauncher.launch(intent);
                } catch (ActivityNotFoundException e) {
                    MainActivity.this.filePathCallback = null;
                    Toast.makeText(MainActivity.this, "Cannot open file chooser", Toast.LENGTH_SHORT).show();
                    return false;
                }
                return true;
            }
        });
    }

    private void setupSwipeRefresh() {
        swipeRefreshLayout.setColorSchemeResources(R.color.binance_gold);
        swipeRefreshLayout.setProgressBackgroundColorSchemeResource(R.color.surface_charcoal);
        swipeRefreshLayout.setOnRefreshListener(() -> {
            errorLayout.setVisibility(View.GONE);
            webView.setVisibility(View.VISIBLE);
            webView.reload();
        });
    }

    private void setupBackNavigation() {
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                if (webView != null && webView.canGoBack()) {
                    webView.goBack();
                } else {
                    long currentTime = System.currentTimeMillis();
                    if (currentTime - lastBackPressTime < 2000) {
                        finish();
                    } else {
                        lastBackPressTime = currentTime;
                        Toast.makeText(MainActivity.this, R.string.exit_prompt, Toast.LENGTH_SHORT).show();
                    }
                }
            }
        });
    }

    private void loadTargetUrl() {
        webView.loadUrl(TARGET_URL);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (webView != null) {
            webView.onResume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (webView != null) {
            webView.onPause();
        }
    }

    @Override
    protected void onDestroy() {
        if (webView != null) {
            webView.destroy();
        }
        super.onDestroy();
    }
}
