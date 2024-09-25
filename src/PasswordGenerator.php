<?php

class PasswordGenerator
{
    /**
     * Gera uma senha com base nos parâmetros fornecidos.
     *
     * @param int $length O comprimento da senha.
     * @param string $keywords Palavras-chave para incluir na senha (opcional).
     * @param bool $useSpecialChars Incluir caracteres especiais.
     * @param bool $useUppercase Incluir letras maiúsculas.
     * @return string A senha gerada.
     */
    public static function generate($length = 8, $keywords = '', $useSpecialChars = false, $useUppercase = false)
    {
        // Definindo os caracteres permitidos
        $characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
        
        if ($useUppercase) {
            $characters .= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        }
        
        if ($useSpecialChars) {
            $characters .= '!@#$%^&*()_+-={}[]|:;<>,.?';
        }

        // Incluindo palavras-chave, se fornecidas
        $password = '';
        if (!empty($keywords)) {
            $password .= $keywords;
            $length -= strlen($keywords); // Ajusta o tamanho para o restante dos caracteres
        }

        // Gerando o restante da senha aleatoriamente
        for ($i = 0; $i < $length; $i++) {
            $password .= $characters[rand(0, strlen($characters) - 1)];
        }

        // Embaralha a senha para misturar as palavras-chave com os caracteres gerados
        return str_shuffle($password);
    }
}
