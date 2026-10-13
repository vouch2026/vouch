-- Migration: event ratings + post-event surveys
-- Rate tab: students submit 1-5 stars (+ optional comment) for ANY past event,
-- one response per (event, user), editable. Officers create custom questions
-- AFTER the event via a per-event survey; answers attach to the response.

-- 1. Surveys (one row per event) -------------------------------------------
CREATE TABLE IF NOT EXISTS event_surveys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL UNIQUE REFERENCES events(id) ON DELETE CASCADE,
  created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  is_open BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Survey questions --------------------------------------------------------
CREATE TABLE IF NOT EXISTS event_survey_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  survey_id UUID NOT NULL REFERENCES event_surveys(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL CHECK (question_type IN ('star', 'text', 'single_choice', 'yes_no')),
  options JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_required BOOLEAN NOT NULL DEFAULT true,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Responses (overall star rating; works even with no survey row) ---------
CREATE TABLE IF NOT EXISTS event_survey_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  survey_id UUID REFERENCES event_surveys(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  overall_rating INT NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (event_id, user_id)
);

-- 4. Per-question answers ----------------------------------------------------
CREATE TABLE IF NOT EXISTS event_survey_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  response_id UUID NOT NULL REFERENCES event_survey_responses(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES event_survey_questions(id) ON DELETE CASCADE,
  answer_text TEXT,
  answer_option TEXT,
  answer_bool BOOLEAN,
  answer_rating INT CHECK (answer_rating IS NULL OR (answer_rating >= 1 AND answer_rating <= 5)),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (response_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_event_surveys_event ON event_surveys(event_id);
CREATE INDEX IF NOT EXISTS idx_survey_questions_survey ON event_survey_questions(survey_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_event ON event_survey_responses(event_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_user ON event_survey_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_survey_answers_response ON event_survey_answers(response_id);
CREATE INDEX IF NOT EXISTS idx_survey_answers_question ON event_survey_answers(question_id);

ALTER TABLE event_surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_survey_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_survey_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_survey_answers ENABLE ROW LEVEL SECURITY;

-- Surveys + questions are visible to everyone (same openness as events).
DROP POLICY IF EXISTS "Surveys are viewable by everyone" ON event_surveys;
CREATE POLICY "Surveys are viewable by everyone" ON event_surveys FOR SELECT USING (true);
DROP POLICY IF EXISTS "Survey questions are viewable by everyone" ON event_survey_questions;
CREATE POLICY "Survey questions are viewable by everyone" ON event_survey_questions FOR SELECT USING (true);

-- Only officers who can edit the parent event manage its survey/questions.
DROP POLICY IF EXISTS "Officers can manage event surveys" ON event_surveys;
CREATE POLICY "Officers can manage event surveys" ON event_surveys
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_surveys.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_surveys.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
    )
  );

DROP POLICY IF EXISTS "Officers can manage survey questions" ON event_survey_questions;
CREATE POLICY "Officers can manage survey questions" ON event_survey_questions
  FOR ALL TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM event_surveys s
      JOIN events e ON e.id = s.event_id
      WHERE s.id = event_survey_questions.survey_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
    )
  )
  WITH CHECK (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM event_surveys s
      JOIN events e ON e.id = s.event_id
      WHERE s.id = event_survey_questions.survey_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
    )
  );

-- Responses: anyone can read aggregates via their own client query, but row
-- reads are limited to the owner + officers of the event scope + super admins.
DROP POLICY IF EXISTS "Owners and officers can view responses" ON event_survey_responses;
CREATE POLICY "Owners and officers can view responses" ON event_survey_responses
  FOR SELECT TO authenticated
  USING (
    auth.uid() = user_id
    OR public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_survey_responses.event_id
      AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
    )
  );

-- Users insert/update/delete only their own response.
DROP POLICY IF EXISTS "Users can insert own response" ON event_survey_responses;
CREATE POLICY "Users can insert own response" ON event_survey_responses
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own response" ON event_survey_responses;
CREATE POLICY "Users can update own response" ON event_survey_responses
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own response" ON event_survey_responses;
CREATE POLICY "Users can delete own response" ON event_survey_responses
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Answers follow the parent response: owner + officers can read; owner writes.
DROP POLICY IF EXISTS "Owners and officers can view answers" ON event_survey_answers;
CREATE POLICY "Owners and officers can view answers" ON event_survey_answers
  FOR SELECT TO authenticated
  USING (
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM event_survey_responses r
      WHERE r.id = event_survey_answers.response_id
      AND (
        r.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM events e
          WHERE e.id = r.event_id
          AND public.has_scope_permission('edit_event', e.scope_type, e.scope_id)
        )
      )
    )
  );

DROP POLICY IF EXISTS "Owners can write answers" ON event_survey_answers;
CREATE POLICY "Owners can write answers" ON event_survey_answers
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM event_survey_responses r
      WHERE r.id = event_survey_answers.response_id
      AND r.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM event_survey_responses r
      WHERE r.id = event_survey_answers.response_id
      AND r.user_id = auth.uid()
    )
  );
