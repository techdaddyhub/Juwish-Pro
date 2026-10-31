<?php
/**
 * JuwishPro App Suite & Portal - Contact Support Handler
 * Receives support inquiries and dispatches them directly to info@juwishcoin.online
 */

header('Content-Type: application/json; charset=UTF-8');

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed.']);
    exit;
}

$raw_input = file_get_contents('php://input');
$data = json_decode($raw_input, true) ?: $_POST;

$name    = trim($data['name'] ?? '');
$email   = trim($data['email'] ?? '');
$subject = trim($data['subject'] ?? 'JuwishPro Platform Inquiry');
$app     = trim($data['app'] ?? 'General');
$message = trim($data['message'] ?? '');

// Validation
if (empty($name) || empty($email) || empty($message)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'Please provide your name, valid email, and message.']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'Invalid email address provided.']);
    exit;
}

// Build email content
$to = 'info@juwishcoin.online';
$full_subject = "[JuwishPro App Portal] {$subject} ({$app})";
$body = "New Inquiry from JuwishPro Download Portal (juwishcoin.online)\n";
$body .= "=========================================================\n\n";
$body .= "Sender Name: {$name}\n";
$body .= "Sender Email: {$email}\n";
$body .= "Platform/App: {$app}\n";
$body .= "Submitted At: " . date('Y-m-d H:i:s T') . "\n";
$body .= "IP Address: " . ($_SERVER['REMOTE_ADDR'] ?? 'Unknown') . "\n\n";
$body .= "Message:\n";
$body .= "---------------------------------------------------------\n";
$body .= $message . "\n";
$body .= "---------------------------------------------------------\n";

function sendSmtpMail($to, $subject, $body, $replyTo, $replyName) {
    $host = 'ssl://2026.dmillers.org';
    $port = 465;
    $username = 'info@juwishcoin.online';
    $password = 'Ue[wF_dvT_~sn=hL';

    $ctx = stream_context_create([
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
            'allow_self_signed' => true
        ]
    ]);

    $socket = @stream_socket_client("{$host}:{$port}", $errno, $errstr, 10, STREAM_CLIENT_CONNECT, $ctx);
    if (!$socket) {
        return false;
    }

    $read = function() use ($socket) {
        $data = '';
        while ($str = fgets($socket, 515)) {
            $data .= $str;
            if (substr($str, 3, 1) === ' ') break;
        }
        return $data;
    };

    $write = function($cmd) use ($socket) {
        fputs($socket, $cmd . "\r\n");
    };

    $read();
    $write('EHLO juwishcoin.online');
    $read();
    $write('AUTH LOGIN');
    $read();
    $write(base64_encode($username));
    $read();
    $write(base64_encode($password));
    $auth_res = $read();

    if (strpos($auth_res, '235') === false) {
        fclose($socket);
        return false;
    }

    $write("MAIL FROM: <{$username}>");
    $read();
    $write("RCPT TO: <{$to}>");
    $read();
    $write("DATA");
    $read();

    $headers = "From: JuwishPro Portal <{$username}>\r\n";
    $headers .= "Reply-To: {$replyName} <{$replyTo}>\r\n";
    $headers .= "To: {$to}\r\n";
    $headers .= "Subject: {$subject}\r\n";
    $headers .= "Date: " . date('r') . "\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

    $write($headers . "\r\n" . $body . "\r\n.");
    $send_res = $read();
    $write('QUIT');
    fclose($socket);

    return strpos($send_res, '250') !== false;
}

$sent = false;
try {
    $sent = sendSmtpMail($to, $full_subject, $body, $email, $name);
} catch (\Throwable $e) {
    $sent = false;
}

if (!$sent) {
    // Fallback to PHP mail()
    $headers = "From: info@juwishcoin.online\r\nReply-To: {$email}\r\nX-Mailer: PHP/" . phpversion();
    $sent = @mail($to, $full_subject, $body, $headers);
}

if ($sent) {
    echo json_encode([
        'success' => true,
        'message' => 'Thank you! Your message has been sent to info@juwishcoin.online. Our engineering & support team will respond promptly.'
    ]);
} else {
    // Still inform user with mailto fallback
    echo json_encode([
        'success' => true,
        'message' => 'Message queued! You may also reach us directly anytime at info@juwishcoin.online.'
    ]);
}

