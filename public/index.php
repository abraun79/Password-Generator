<?php
require 'src/PasswordGenerator.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $length = $_POST['length'];
    $keywords = $_POST['keywords'];
    $useSpecialChars = isset($_POST['special_chars']);
    $useUppercase = isset($_POST['uppercase']);
    $quantity = $_POST['quantity'];
    
    $passwords = [];
    for ($i = 0; $i < $quantity; $i++) {
        $passwords[] = PasswordGenerator::generate($length, $keywords, $useSpecialChars, $useUppercase);
    }
    
    echo "Senhas Geradas:<br>";
    foreach ($passwords as $password) {
        echo htmlspecialchars($password) . "<br>";
    }
} else {
    include 'templates/form.html';
}
