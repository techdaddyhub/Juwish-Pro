<?php
/**
 * JuwishPro - cPanel Automated Initialization & Permission Tool
 * URL: https://2026.dmillers.org/cpanel-setup.php
 */

header('Content-Type: text/html; charset=utf-8');

$baseDir = realpath(__DIR__ . '/..');
$storageDir = $baseDir . '/storage';
$bootstrapCacheDir = $baseDir . '/bootstrap/cache';

$actionsDone = [];
$errors = [];

// 1. Ensure storage subdirectories exist and have 775 permissions
$dirsToCreate = [
    $storageDir,
    $storageDir . '/app',
    $storageDir . '/app/public',
    $storageDir . '/framework',
    $storageDir . '/framework/cache',
    $storageDir . '/framework/cache/data',
    $storageDir . '/framework/sessions',
    $storageDir . '/framework/views',
    $storageDir . '/logs',
    $storageDir . '/debugbar',
    $storageDir . '/untranslated',
    $bootstrapCacheDir
];

foreach ($dirsToCreate as $dir) {
    if (!is_dir($dir)) {
        if (@mkdir($dir, 0775, true)) {
            $actionsDone[] = "Created directory: " . htmlspecialchars(substr($dir, strlen($baseDir)));
        } else {
            $errors[] = "Could not create directory: " . htmlspecialchars(substr($dir, strlen($baseDir)));
        }
    }
    @chmod($dir, 0775);
}

// 2. Storage symlink
$publicStorage = __DIR__ . '/storage';
if (!file_exists($publicStorage)) {
    if (@symlink('../storage/app/public', $publicStorage)) {
        $actionsDone[] = "Created storage symlink (public/storage -> storage/app/public)";
    }
}

// 3. Clear file view caches if any
$viewCache = $storageDir . '/framework/views';
if (is_dir($viewCache)) {
    $files = glob($viewCache . '/*');
    foreach ($files as $f) {
        if (is_file($f) && basename($f) !== '.gitignore') {
            @unlink($f);
        }
    }
    $actionsDone[] = "Cleaned compiled Blade view cache";
}

// Check PHP extensions
$requiredExts = ['openssl', 'pdo', 'pdo_mysql', 'mbstring', 'tokenizer', 'xml', 'ctype', 'json', 'bcmath', 'curl', 'fileinfo'];
$extStatus = [];
foreach ($requiredExts as $ext) {
    $extStatus[$ext] = extension_loaded($ext);
}

$phpVersion = PHP_VERSION;
$phpOk = version_compare($phpVersion, '8.2.0', '>=');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JuwishPro | cPanel Initialization & Setup</title>
    <link rel="icon" type="image/png" href="assets/images/favicon.png">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
        body { background: #0B0E11; color: #EAECEF; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
        .card { max-width: 680px; width: 100%; background: #181A20; border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 24px; padding: 36px; box-shadow: 0 20px 50px rgba(0,0,0,0.8); }
        .header { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 20px; }
        .header img { width: 48px; height: 48px; border-radius: 50%; }
        h1 { color: #FFFFFF; font-size: 24px; font-weight: 800; }
        h1 span { color: #F0B90B; }
        .badge { background: rgba(240,185,11,0.15); border: 1px solid rgba(240,185,11,0.3); color: #F0B90B; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 20px; text-transform: uppercase; }
        .section { margin-bottom: 24px; }
        .section-title { font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #848E9C; margin-bottom: 12px; font-weight: 700; }
        .item-list { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 14px 18px; }
        .item { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.04); font-size: 14px; }
        .item:last-child { border-bottom: none; }
        .success { color: #0ECB81; font-weight: 700; }
        .error { color: #F6465D; font-weight: 700; }
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 14px 28px; background: #F0B90B; color: #000000; font-weight: 800; font-size: 14px; text-decoration: none; border-radius: 12px; transition: 0.2s; border: none; cursor: pointer; }
        .btn:hover { background: #FCD535; transform: scale(1.02); }
        .btn-outline { background: transparent; color: #EAECEF; border: 1px solid rgba(255,255,255,0.15); }
        .btn-outline:hover { background: rgba(255,255,255,0.06); }
        .actions { display: flex; gap: 12px; margin-top: 28px; flex-wrap: wrap; }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <img src="assets/images/juwishcoin.png" alt="JuwishPro">
            <div>
                <h1>Juwish<span>Pro</span> cPanel Initializer</h1>
                <p style="color: #848E9C; font-size: 13px;">Target Domain: <strong>2026.dmillers.org</strong></p>
            </div>
            <div style="margin-left: auto;">
                <span class="badge">Binance Theme Active</span>
            </div>
        </div>

        <div class="section">
            <div class="section-title">Permissions & Directory Status</div>
            <div class="item-list">
                <?php foreach ($actionsDone as $msg): ?>
                    <div class="item">
                        <span><?= $msg ?></span>
                        <span class="success">✓ READY</span>
                    </div>
                <?php endforeach; ?>
                <div class="item">
                    <span>storage/ (Write Permissions)</span>
                    <span class="<?= is_writable($storageDir) ? 'success' : 'error' ?>">
                        <?= is_writable($storageDir) ? '775 (OK)' : 'NOT WRITABLE' ?>
                    </span>
                </div>
                <div class="item">
                    <span>bootstrap/cache/ (Write Permissions)</span>
                    <span class="<?= is_writable($bootstrapCacheDir) ? 'success' : 'error' ?>">
                        <?= is_writable($bootstrapCacheDir) ? '775 (OK)' : 'NOT WRITABLE' ?>
                    </span>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-title">PHP Environment Checks</div>
            <div class="item-list">
                <div class="item">
                    <span>PHP Version (<?= htmlspecialchars($phpVersion) ?>)</span>
                    <span class="<?= $phpOk ? 'success' : 'error' ?>"><?= $phpOk ? 'PASSED (8.2+)' : 'UPGRADE TO 8.2+' ?></span>
                </div>
                <?php foreach ($extStatus as $ext => $loaded): ?>
                    <div class="item">
                        <span>Extension: <?= htmlspecialchars($ext) ?></span>
                        <span class="<?= $loaded ? 'success' : 'error' ?>"><?= $loaded ? 'ENABLED' : 'MISSING' ?></span>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="actions">
            <a href="/install/index.php" class="btn">Launch Web Installer →</a>
            <a href="/" class="btn btn-outline">Visit Homepage</a>
        </div>
    </div>
</body>
</html>

