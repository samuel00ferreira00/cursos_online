
# 🎓 Plataforma de Cursos Online

![GitHub Repo stars](https://img.shields.io/github/stars/samuel00ferreira00/cursos_online?style=social)
 
---

## 🚀 Sobre o Projeto

A **Plataforma de Cursos Online** é um sistema completo para gestão de cursos, alunos, professores e avaliações, desenvolvido para facilitar o ensino a distância com controle detalhado do progresso dos alunos.

💡 **Destaques:**
- Gerenciamento de utilizadores (Alunos, Professores, Admins)
- Cadastro de cursos e categorias
- Matrículas e progresso automático de conclusão
- Relatórios gerenciais poderosos
- Triggers e Procedures para automação

---

## 📚 Índice

- [💾 Modelo de Dados](#-modelo-de-dados)
- [📊 Consultas e Relatórios](#-consultas-e-relatórios)
- [⚙️ Procedures e Triggers](#️-procedures-e-triggers)
- [🚀 Boas Práticas de Performance](#-boas-práticas-de-performance)
- [🛠 Como Rodar](#-como-rodar)
- [🧰 Tecnologias](#-tecnologias)
- [📬 Contato](#-contato)

---

## 💾 Modelo de Dados

Tabela | Descrição
--- | ---
`utilizadores` | Armazena todos os utilizadores (Alunos, Professores, Admins)
`categorias` | Categorias dos cursos
`cursos` | Cursos disponíveis com link ao professor e categoria
`matriculas` | Matrículas de alunos nos cursos
`avaliacoes` | Comentários e notas dos alunos para cursos
`aulas` | Conteúdo em aulas com ordem e tempo estimado
`progresso_aulas` | Marca aulas assistidas pelos alunos

---

## 📊 Consultas e Relatórios

Veja alguns exemplos que facilitam o gerenciamento e análise da plataforma:

### 🔥 Cursos mais populares

```sql
SELECT c.titulo AS "Curso", COUNT(m.id_utilizador) AS "Alunos"
FROM cursos c
JOIN matriculas m ON c.id = m.id_curso
GROUP BY c.id
ORDER BY COUNT(m.id_utilizador) DESC
LIMIT 10;
```

### 👩‍🏫 Professores com mais cursos publicados

```sql
SELECT u.nome AS "Professor", COUNT(c.id) AS "Cursos Ministrados"
FROM utilizadores u
JOIN cursos c ON u.id = c.id_professor
WHERE u.papel = 'professor'
GROUP BY u.id
ORDER BY COUNT(c.id) DESC
LIMIT 10;
```

### ⭐ Média de avaliações por curso

```sql
SELECT c.titulo, ROUND(AVG(a.nota), 2) AS media
FROM avaliacoes a
JOIN cursos c ON a.id_curso = c.id
GROUP BY c.id;
```

---

## ⚙️ Procedures e Triggers

### ⚡ Trigger: Marca curso como concluído automaticamente

Ao assistir todas as aulas de um curso, o aluno tem a matrícula marcada como concluída.

```sql
CREATE TRIGGER trigger_marcar_curso_concluido
AFTER INSERT ON progresso_aulas
FOR EACH ROW
BEGIN
    -- Lógica para verificar progresso e atualizar matrícula
END;
```

### 📋 Procedure: Listar cursos por professor

Consulta prática para listar cursos vinculados a um professor.

```sql
CREATE PROCEDURE listar_cursos_por_professor(IN prof_id INT)
BEGIN
    SELECT id, titulo, descricao, data_criacao, Ativo
    FROM cursos
    WHERE id_professor = prof_id;
END;
```

---


## 🛠 Como Rodar

1. Clone o repositório:
```bash
git clone https://github.com/samuel00ferreira00/cursos_online.git
```

2. Importe o script SQL no seu banco de dados (MySQL/MariaDB):

```bash
mysql -u usuario -p banco_de_dados < script.sql
```

3. Use seu gerenciador favorito para executar consultas, procedures e triggers.

---

## 🧰 Tecnologias

- Banco de dados relacional: **MySQL** 
- Ferramenta utilizada: XAMPP
- Linguagem SQL para criação de esquema, consultas, procedures e triggers

---

## 📬 Contato

| 📧 Email            | 🔗 LinkedIn                        | 🐱 GitHub                       |
|---------------------|----------------------------------|--------------------------------|
| email@exemplo.com   | [linkedin.com/in/seunome](https://linkedin.com/in/seunome) | [github.com/seunome](https://github.com/seunome) |

---

<p align="center">
  Desenvolvido por  Samuel Ferreira
</p>
