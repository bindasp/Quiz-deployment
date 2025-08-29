CREATE OR REPLACE FUNCTION calculate_test_score(p_user_id INTEGER, p_test_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_total_score NUMERIC := 0;
    v_question RECORD;
    v_correct_count INTEGER;
    v_incorrect_count INTEGER;
    v_question_score NUMERIC;
    v_selected RECORD;
BEGIN
    -- Przejście przez wszystkie pytania w teście
    FOR v_question IN
        SELECT question_number
        FROM "Questions"
        WHERE test_id = p_test_id
    LOOP
        -- Liczba poprawnych odpowiedzi
        SELECT COUNT(*) INTO v_correct_count
        FROM "Answers"
        WHERE test_id = p_test_id
          AND question_number = v_question.question_number
          AND is_correct = TRUE;

        -- Liczba niepoprawnych odpowiedzi
        SELECT COUNT(*) INTO v_incorrect_count
        FROM "Answers"
        WHERE test_id = p_test_id
          AND question_number = v_question.question_number
          AND is_correct = FALSE;

        -- Jeżeli brak poprawnych odpowiedzi, omijamy pytanie (żeby uniknąć dzielenia przez 0)
        IF v_correct_count = 0 THEN
            CONTINUE;
        END IF;

        v_question_score := 0;

        -- Sprawdzamy odpowiedzi użytkownika dla danego pytania
        FOR v_selected IN
            SELECT aa.answer_number, a.is_correct
            FROM "Attempt_Answers" aa
            JOIN "Answers" a
              ON a.test_id = aa.test_id
             AND a.question_number = aa.question_number
             AND a.answer_number = aa.answer_number
            WHERE aa.user_id = p_user_id
              AND aa.test_id = p_test_id
              AND aa.question_number = v_question.question_number
        LOOP
            IF v_selected.is_correct THEN
                -- Poprawna odpowiedź: dodajemy 1/liczba_poprawnych
                v_question_score := v_question_score + (1.0 / v_correct_count);
            ELSE
                -- Niepoprawna odpowiedź: odejmujemy 1/liczba_niepoprawnych (jeśli są niepoprawne)
                IF v_incorrect_count > 0 THEN
                    v_question_score := v_question_score - (1.0 / v_incorrect_count);
                END IF;
            END IF;
        END LOOP;

        -- Nie pozwalamy na ujemny wynik za pytanie
        IF v_question_score < 0 THEN
            v_question_score := 0;
        END IF;

        -- Sumujemy wynik pytania do całkowitego wyniku
        v_total_score := v_total_score + v_question_score;
    END LOOP;

    RETURN v_total_score;
END;
$$ LANGUAGE plpgsql;
