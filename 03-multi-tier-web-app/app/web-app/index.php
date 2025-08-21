<?php
$servername = "DB_HOST_PLACEHOLDER";
$username = "DB_USER_PLACEHOLDER";
$password = "DB_PASSWORD_PLACEHOLDER";
$dbname = "DB_NAME_PLACEHOLDER";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "<h1>Hello from Multi-Tier Web App!</h1>";
echo "<p>Successfully connected to MySQL database using PHP!</p>";

// Example: Create a table if it doesn't exist
$sql = "CREATE TABLE IF NOT EXISTS messages (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255))";
if ($conn->query($sql) === TRUE) {
    echo "<p>Table 'messages' checked/created successfully</p>";
} else {
    echo "<p>Error creating table: " . $conn->error . "</p>";
}

// Example: Insert a message
$message = "Hello from " . gethostname() . " at " . date("Y-m-d H:i:s");
$sql = "INSERT INTO messages (message) VALUES ('" . $message . "')";
if ($conn->query($sql) === TRUE) {
    echo "<p>New record created successfully</p>";
} else {
    echo "<p>Error: " . $sql . "<br>" . $conn->error . "</p>";
}

// Example: Retrieve and display messages
$sql = "SELECT id, message FROM messages";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo "<h2>Messages:</h2>";
    echo "<ul>";
    while($row = $result->fetch_assoc()) {
        echo "<li>id: " . $row["id"]. " - Message: " . $row["message"]. "</li>";
    }
    echo "</ul>";
} else {
    echo "<p>No messages found.</p>";
}

$conn->close();
?>


