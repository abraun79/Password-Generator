#!/bin/bash

# Verifica se o usuário é root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root."
  exit
fi

echo "Atualizando o sistema..."
apt update && apt upgrade -y

echo "Instalando pacotes necessários (Apache, PHP)..."
apt install apache2 php libapache2-mod-php -y

# Configurações do Apache
echo "Habilitando o módulo rewrite do Apache..."
a2enmod rewrite
systemctl restart apache2

# Definindo diretório da aplicação
APP_DIR="/var/www/html/password_generator"

echo "Criando diretórios da aplicação..."
mkdir -p "$APP_DIR/src"
mkdir -p "$APP_DIR/templates"

# Criando index.php
echo "Criando index.php..."
cat > "$APP_DIR/index.php" <<EOL
<?php
require 'src/PasswordGenerator.php';

if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
    \$length = filter_input(INPUT_POST, 'length', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1, 'default' => 8]]);
    \$keywords = filter_input(INPUT_POST, 'keywords', FILTER_SANITIZE_STRING);
    \$useSpecialChars = isset(\$_POST['special_chars']);
    \$useUppercase = isset(\$_POST['uppercase']);
    \$quantity = filter_input(INPUT_POST, 'quantity', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1, 'default' => 1]]);
    
    \$passwords = [];
    for (\$i = 0; \$i < \$quantity; \$i++) {
        \$passwords[] = PasswordGenerator::generate(\$length, \$keywords, \$useSpecialChars, \$useUppercase);
    }

    echo "<h2>Senhas Geradas:</h2><ul>";
    foreach (\$passwords as \$password) {
        echo "<li>" . htmlspecialchars(\$password) . "</li>";
    }
    echo "</ul>";
} else {
    include 'templates/form.html';
}
EOL

# Criando PasswordGenerator.php
echo "Criando src/PasswordGenerator.php..."
cat > "$APP_DIR/src/PasswordGenerator.php" <<EOL
<?php

class PasswordGenerator
{
    public static function generate(\$length = 8, \$keywords = '', \$useSpecialChars = false, \$useUppercase = false)
    {
        \$characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
        
        if (\$useUppercase) {
            \$characters .= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        }

        if (\$useSpecialChars) {
            \$characters .= '!@#$%^&*()_+-={}[]|:;<>,.?';
        }

        \$password = '';
        if (!empty(\$keywords)) {
            \$password .= \$keywords;
            \$length -= strlen(\$keywords);
        }

        for (\$i = 0; \$i < \$length; \$i++) {
            \$password .= \$characters[rand(0, strlen(\$characters) - 1)];
        }

        return str_shuffle(\$password);
    }
}
EOL

# Criando form.html
echo "Criando templates/form.html..."
cat > "$APP_DIR/templates/form.html" <<EOL
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gerador de Senhas</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        input, select {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        label {
            margin: 5px 0;
        }
        button {
            padding: 10px 15px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>Gerador de Senhas</h1>
    <form action="index.php" method="POST">
        <label for="length">Comprimento da Senha:</label>
        <input type="number" id="length" name="length" value="8" min="1" required>
        
        <label for="keywords">Palavras-chave (opcional):</label>
        <input type="text" id="keywords" name="keywords">
        
        <label for="quantity">Quantidade de Senhas:</label>
        <input type="number" id="quantity" name="quantity" value="1" min="1" required>
        
        <label>
            <input type="checkbox" name="special_chars"> Incluir Caracteres Especiais
        </label>
        
        <label>
            <input type="checkbox" name="uppercase"> Incluir Letras Maiúsculas
        </label>
        
        <button type="submit">Gerar Senhas</button>
    </form>
</div>

</body>
</html>
EOL

# Definir permissões corretas
echo "Ajustando permissões..."
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"

# Reiniciar Apache
echo "Reiniciando o Apache..."
systemctl restart apache2

echo "Instalação concluída! Acesse http://localhost/password_generator para usar o gerador de senhas."
