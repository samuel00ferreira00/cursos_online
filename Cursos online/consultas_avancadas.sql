
#RELATÓRIOS GERENCIAIS
/*------------------------------------------------------------------------------------------------------------------------------
1. Cursos mais populares (por nmero de matrculas)
------------------------------------------------------------------------------------------------------------------------------*/
SELECT c.titulo as "Título do curso",COUNT(m.id_utilizador) as "Qtd de alunos"
FROM `cursos` as c 
INNER JOIN 
	matriculas as m ON c.id = m.id_curso 
GROUP BY 
	(c.id)
ORDER BY 
	(COUNT(m.id_utilizador)) DESC
LIMIT 10;
/*------------------------------------------------------------------------------------------------------------------------------
2. Professores com mais cursos publicados
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	u.nome as "Nome professor",COUNT(c.id) as "Cursos ministrados"
FROM `utilizadores` as u
INNER JOIN 
	cursos as c ON u.id = c.id_professor
WHERE 
	u.papel = 'professor'
GROUP BY 
	u.id
ORDER BY
	COUNT(c.id) DESC
LIMIT 10;
/*------------------------------------------------------------------------------------------------------------------------------
3. Média de avaliações por curso
------------------------------------------------------------------------------------------------------------------------------*/
SELECT c.titulo as "Nome do curso",
	ROUND(AVG(a.nota),2) as "Média de avaliações"
FROM `avaliacoes` as a
INNER JOIN 
	cursos as c ON a.id_curso = c.id
GROUP BY 
	c.id;
/*------------------------------------------------------------------------------------------------------------------------------
4. Quantidade de cursos por categoria
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	cat.nome AS 'Nome da categoria',COUNT(c.id) AS 'Qtd de cursos'
FROM `cursos` AS c
INNER JOIN
	categorias as cat ON c.id_categoria = cat.id
GROUP BY  
	cat.id;
/*------------------------------------------------------------------------------------------------------------------------------
5. Total de utilizadores por papel
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	u.papel,COUNT(*) AS 'Total de utlizadores por papel'
FROM `utilizadores` AS u
GROUP BY 
	papel;


/*------------------------------------------------------------------------------------------------------------------------------
6. Cursos concluídos por aluno
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	u.nome, COUNT(*) AS 'Cursos concluídos' FROM matriculas m
INNER JOIN 
utilizadores u ON u.id = m.id_utilizador
WHERE 
	m.concluido = 1 
GROUP BY 
	u.id;
/*------------------------------------------------------------------------------------------------------------------------------
7. Média de avaliaçõs de curso por professor
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	u.nome,c.titulo AS 'Nome curso',ROUND(AVG(a.nota), 2) AS 'Média'
FROM cursos c 
INNER JOIN 
	utilizadores u ON c.id_professor = u.id
INNER JOIN 
	avaliacoes a ON c.id = a.id_curso
WHERE 
	u.papel = 'professor'
GROUP BY 
	u.id;
/*------------------------------------------------------------------------------------------------------------------------------
8. Total de alunos por curso de cada professor
------------------------------------------------------------------------------------------------------------------------------*/
SELECT
	u.nome AS professor, c.titulo, COUNT(m.id_utilizador) AS 'Qtd alunos'
FROM cursos c 
INNER JOIN 
	utilizadores u ON u.id = c.id_professor
LEFT JOIN 
	matriculas m ON m.id_curso = c.id
GROUP BY 
	c.id, u.id;
/*------------------------------------------------------------------------------------------------------------------------------
9. Lista de cursos ativos/inativos
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	titulo, ativo 
 FROM cursos 
 ORDER BY 
 	ativo DESC;
/*------------------------------------------------------------------------------------------------------------------------------
10. Alunos ativos matrículados
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	DISTINCT 
    	u.nome 
FROM utilizadores u
INNER JOIN 
	matriculas m ON u.id = m.id_utilizador
WHERE 
	u.ativo = 1;
/*------------------------------------------------------------------------------------------------------------------------------
11. Cursos sem avaliações
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	c.titulo 
FROM cursos c
LEFT JOIN 
	avaliacoes a ON a.id_curso = c.id
WHERE 
a.id IS NULL;
/*------------------------------------------------------------------------------------------------------------------------------
12. Aulas com tempo acima da média
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	titulo, tempo_estimado 
FROM aulas
WHERE 
	tempo_estimado > (SELECT AVG(tempo_estimado) FROM aulas);
/*------------------------------------------------------------------------------------------------------------------------------
13. Cursos com menos aulas que a média
------------------------------------------------------------------------------------------------------------------------------*/

WITH total_aulas_por_curso AS (
    SELECT 
        id_curso,
        COUNT(*) AS total_aulas
    FROM aulas
    GROUP BY id_curso
),
media_aulas AS (
    SELECT 
        AVG(total_aulas) AS media_geral
    FROM total_aulas_por_curso
)
SELECT 
    c.titulo,
    u.nome AS professor,
    tac.total_aulas,
    ROUND(m.media_geral, 2) AS media_geral
FROM total_aulas_por_curso tac
JOIN cursos c ON tac.id_curso = c.id
JOIN utilizadores u ON c.id_professor = u.id
CROSS JOIN media_aulas m
WHERE tac.total_aulas < m.media_geral;
/*------------------------------------------------------------------------------------------------------------------------------
14. Últimos cursos criados
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	titulo,data_criacao 
FROM `cursos`
ORDER BY 
	data_criacao DESC;
/*------------------------------------------------------------------------------------------------------------------------------
15. Alunos com mais matrículas que a média
------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
    u.id,
    u.nome,
    COUNT(m.id_curso) AS total_matriculas
FROM utilizadores u
JOIN matriculas m ON u.id = m.id_utilizador
WHERE u.papel = 'Aluno'
GROUP BY u.id, u.nome
HAVING COUNT(m.id_curso) > (
    SELECT AVG(qtd) FROM (
        SELECT COUNT(id_curso) AS qtd
        FROM matriculas
        GROUP BY id_utilizador
    ) AS subquery
);

/*------------------------------------------------------------------------------------------------------------------------------
16. VIEW Progresso por curso
------------------------------------------------------------------------------------------------------------------------------*/
CREATE VIEW progresso_por_curso AS
SELECT 
    u.id AS 'ID Aluno',
    u.nome AS 'Nome do aluno',
    c.id AS 'ID Curso',
    c.titulo AS 'Nome do curso',
    COUNT(DISTINCT a.id) AS total_aulas,
    COUNT(DISTINCT pa.id_aula) AS aulas_assistidas,
    ROUND((COUNT(DISTINCT pa.id_aula) * 100.0 / COUNT(DISTINCT a.id)), 2) AS porcentagem_progresso
FROM cursos c
JOIN aulas a ON a.id_curso = c.id
JOIN matriculas m ON m.id_curso = c.id
JOIN utilizadores u ON u.id = m.id_utilizador
LEFT JOIN progresso_aulas pa 
    ON pa.id_utilizador = u.id AND pa.id_aula = a.id
GROUP BY u.id, u.nome, c.id, c.titulo;

/*------------------------------------------------------------------------------------------------------------------------------
17. TRIGGER Marcar curso como concluído automaticamente
------------------------------------------------------------------------------------------------------------------------------*/
DELIMITER $$

CREATE TRIGGER trigger_marcar_curso_concluido
AFTER INSERT ON progresso_aulas
FOR EACH ROW
BEGIN
    DECLARE total_aulas INT;
    DECLARE aulas_assistidas INT;
    DECLARE curso_id INT;

    -- Obter o curso da aula assistida
    SELECT id_curso INTO curso_id
    FROM aulas
    WHERE id = NEW.id_aula;

    -- Contar o total de aulas do curso
    SELECT COUNT(*) INTO total_aulas
    FROM aulas
    WHERE id_curso = curso_id;

    -- Contar quantas aulas o aluno já assistiu desse curso
    SELECT COUNT(*) INTO aulas_assistidas
    FROM progresso_aulas pa
    JOIN aulas a ON a.id = pa.id_aula
    WHERE pa.id_utilizador = NEW.id_utilizador
      AND a.id_curso = curso_id
      AND pa.assistido = 1;

    -- Se o aluno assistiu todas as aulas, marcar como concluído
    IF total_aulas = aulas_assistidas THEN
        UPDATE matriculas
        SET concluido = 1
        WHERE id_utilizador = NEW.id_utilizador
          AND id_curso = curso_id;
    END IF;
END$$

DELIMITER ;

/*------------------------------------------------------------------------------------------------------------------------------
18. PROCEDURE Listar cursos por professor
------------------------------------------------------------------------------------------------------------------------------*/
DELIMITER $$

CREATE PROCEDURE listar_cursos_por_professor(IN prof_id INT)
BEGIN
    SELECT 
        c.id AS id_curso,
        c.titulo,
        c.descricao,
        c.data_criacao,
        c.Ativo
    FROM cursos c
    JOIN utilizadores u ON u.id = c.id_professor
    WHERE c.id_professor = prof_id
      AND u.papel = 'professor';
END$$

DELIMITER ;

