-- Migration: 09_comselec_architecture_schema.sql
-- Description: Complete schema for VouchEDU COMSELEC Architecture including Elections, Positions, Candidates, Voter Eligibility, Commission Assignments, Ballots, Offline Sync, Audit, Announcements, Guidelines, and Incidents.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'election_scope_type') THEN
        CREATE TYPE election_scope_type AS ENUM ('campus', 'faculty', 'program');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'election_lifecycle_status') THEN
        CREATE TYPE election_lifecycle_status AS ENUM (
            'DRAFT', 'CONFIGURATION', 'CANDIDATE_FILING', 'CANDIDATE_REVIEW',
            'VOTER_VERIFICATION', 'PUBLISHED', 'VOTING_OPEN', 'VOTING_CLOSED',
            'RECONCILIATION', 'CERTIFIED', 'RESULTS_PUBLISHED', 'ARCHIVED', 'CANCELLED'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'position_voting_type') THEN
        CREATE TYPE position_voting_type AS ENUM ('single_choice', 'multiple_choice', 'rank_choice');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'application_status') THEN
        CREATE TYPE application_status AS ENUM ('PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'RETURNED_FOR_CORRECTION');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'eligibility_status') THEN
        CREATE TYPE eligibility_status AS ENUM ('PENDING', 'ELIGIBLE', 'INELIGIBLE', 'MANUAL_REVIEW', 'SUSPENDED');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'offline_sync_status') THEN
        CREATE TYPE offline_sync_status AS ENUM ('LOCAL_PENDING', 'SYNCING', 'SYNCED', 'REJECTED', 'REQUIRES_REVIEW');
    END IF;
END $$;

-- 1. Elections Table
CREATE TABLE IF NOT EXISTS public.elections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    election_type VARCHAR(50) NOT NULL, -- Campus-wide, Faculty, Program
    scope_type election_scope_type NOT NULL DEFAULT 'campus',
    campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
    faculty_id UUID REFERENCES public.faculties(id) ON DELETE SET NULL,
    program_id UUID REFERENCES public.programs(id) ON DELETE SET NULL,
    academic_year_id UUID REFERENCES public.academic_years(id) ON DELETE SET NULL,
    semester_id UUID REFERENCES public.semesters(id) ON DELETE SET NULL,
    status election_lifecycle_status NOT NULL DEFAULT 'DRAFT',
    logo_url VARCHAR(512),
    banner_url VARCHAR(512),
    is_online_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    is_offline_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    filing_start_at TIMESTAMPTZ,
    filing_end_at TIMESTAMPTZ,
    review_end_at TIMESTAMPTZ,
    voting_start_at TIMESTAMPTZ,
    voting_end_at TIMESTAMPTZ,
    results_publication_at TIMESTAMPTZ,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Election Positions Table
CREATE TABLE IF NOT EXISTS public.election_positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    seat_count INT NOT NULL DEFAULT 1,
    max_candidate_limit INT,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    allow_abstain BOOLEAN NOT NULL DEFAULT TRUE,
    voting_type position_voting_type NOT NULL DEFAULT 'single_choice',
    display_order INT NOT NULL DEFAULT 0,
    eligibility_rules JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Candidate Applications Table
CREATE TABLE IF NOT EXISTS public.candidate_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    position_id UUID NOT NULL REFERENCES public.election_positions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    platform_statement TEXT,
    document_urls JSONB DEFAULT '[]'::jsonb,
    status application_status NOT NULL DEFAULT 'PENDING',
    review_notes TEXT,
    rejection_reason TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ
);

-- 4. Approved Election Candidates Table
CREATE TABLE IF NOT EXISTS public.election_candidates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    position_id UUID NOT NULL REFERENCES public.election_positions(id) ON DELETE CASCADE,
    application_id UUID UNIQUE REFERENCES public.candidate_applications(id) ON DELETE SET NULL,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    display_name VARCHAR(255) NOT NULL,
    ballot_order INT NOT NULL DEFAULT 0,
    photo_url VARCHAR(512),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Election Voter Eligibility Table
CREATE TABLE IF NOT EXISTS public.election_voter_eligibility (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    eligibility_status eligibility_status NOT NULL DEFAULT 'PENDING',
    ineligibility_reason TEXT,
    verification_source VARCHAR(100) DEFAULT 'SYSTEM_AUTO',
    verified_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    verified_at TIMESTAMPTZ,
    CONSTRAINT unique_election_voter UNIQUE (election_id, student_id)
);

-- 6. Commission Assignments Table
CREATE TABLE IF NOT EXISTS public.election_commission_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL, -- chairman, co_chairman, campus_commissioner, faculty_commissioner, program_commissioner
    campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
    faculty_id UUID REFERENCES public.faculties(id) ON DELETE SET NULL,
    program_id UUID REFERENCES public.programs(id) ON DELETE SET NULL,
    permissions JSONB NOT NULL DEFAULT '[]'::jsonb,
    starts_at TIMESTAMPTZ,
    ends_at TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 7. Secret Voter Submissions Ledger (Voter ID tracking - NO SELECTIONS)
CREATE TABLE IF NOT EXISTS public.voter_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    submission_mode VARCHAR(20) NOT NULL DEFAULT 'online', -- online, offline
    station_id UUID,
    receipt_hash VARCHAR(128) NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_election_voter_submission UNIQUE (election_id, voter_id)
);

-- 8. Anonymous Ballots Table (Vote Choice Tracking - NO USER ID)
CREATE TABLE IF NOT EXISTS public.ballots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    ballot_reference VARCHAR(64) UNIQUE NOT NULL,
    voting_mode VARCHAR(20) NOT NULL DEFAULT 'online', -- online, offline
    transaction_id VARCHAR(128) UNIQUE NOT NULL,
    station_id UUID,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    synchronized_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 9. Ballot Selections Table
CREATE TABLE IF NOT EXISTS public.ballot_selections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ballot_id UUID NOT NULL REFERENCES public.ballots(id) ON DELETE CASCADE,
    position_id UUID NOT NULL REFERENCES public.election_positions(id) ON DELETE CASCADE,
    candidate_id UUID REFERENCES public.election_candidates(id) ON DELETE SET NULL,
    is_abstain BOOLEAN NOT NULL DEFAULT FALSE
);

-- 10. Offline Voting Stations Table
CREATE TABLE IF NOT EXISTS public.voting_stations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    device_identifier VARCHAR(255) NOT NULL,
    station_name VARCHAR(150) NOT NULL,
    location TEXT NOT NULL,
    registered_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    public_key TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'REGISTERED', -- REGISTERED, ACTIVE, LOCKED, DECOMMISSIONED
    registered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_sync_at TIMESTAMPTZ
);

-- 11. Offline Transactions Queue Table
CREATE TABLE IF NOT EXISTS public.offline_vote_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    station_id UUID NOT NULL REFERENCES public.voting_stations(id) ON DELETE CASCADE,
    local_transaction_id VARCHAR(128) NOT NULL,
    payload_hash VARCHAR(128) NOT NULL,
    voter_token_hash VARCHAR(128) NOT NULL,
    encrypted_payload TEXT NOT NULL,
    sync_status offline_sync_status NOT NULL DEFAULT 'LOCAL_PENDING',
    rejection_reason TEXT,
    received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    CONSTRAINT unique_station_local_tx UNIQUE (station_id, local_transaction_id)
);

-- 12. Election Audit Logs Table
CREATE TABLE IF NOT EXISTS public.election_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    actor_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id UUID,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. Election Announcements Table
CREATE TABLE IF NOT EXISTS public.election_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    target_scope VARCHAR(50) NOT NULL DEFAULT 'ALL', -- ALL, FACULTY, PROGRAM, CANDIDATES, COMMISSIONERS
    published_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED',
    published_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 14. Election Guidelines Table
CREATE TABLE IF NOT EXISTS public.election_guidelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    version VARCHAR(20) NOT NULL DEFAULT '1.0',
    published_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    published_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 15. Election Incident Records Table
CREATE TABLE IF NOT EXISTS public.election_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    incident_reference VARCHAR(64) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    reported_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    assigned_reviewer_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN', -- OPEN, UNDER_REVIEW, RESOLVED, DISMISSED
    resolution_notes TEXT,
    reported_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ
);

-- Enable RLS on all COMSELEC tables
ALTER TABLE public.elections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidate_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_voter_eligibility ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_commission_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voter_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ballots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ballot_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_vote_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_guidelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_incidents ENABLE ROW LEVEL SECURITY;

-- Permissive RLS Policies for Authenticated Application Users (controlled via RPC & backend permissions)
CREATE POLICY "Allow authenticated read elections" ON public.elections FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated manage elections" ON public.elections FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read positions" ON public.election_positions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated manage positions" ON public.election_positions FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read candidates" ON public.election_candidates FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated manage candidates" ON public.election_candidates FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read candidate_applications" ON public.candidate_applications FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert candidate_applications" ON public.candidate_applications FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update candidate_applications" ON public.candidate_applications FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read eligibility" ON public.election_voter_eligibility FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated manage eligibility" ON public.election_voter_eligibility FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read assignments" ON public.election_commission_assignments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated manage assignments" ON public.election_commission_assignments FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read submissions" ON public.voter_submissions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read announcements" ON public.election_announcements FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read guidelines" ON public.election_guidelines FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read incidents" ON public.election_incidents FOR SELECT TO authenticated USING (true);

-- 16. Secure Online Ballot Submission RPC
CREATE OR REPLACE FUNCTION public.submit_online_ballot(
    p_election_id UUID,
    p_selections JSONB
)
RETURNS TABLE (
    success BOOLEAN,
    receipt_hash VARCHAR,
    message VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
    v_election RECORD;
    v_eligible BOOLEAN;
    v_existing_submission BOOLEAN;
    v_ballot_id UUID;
    v_receipt VARCHAR(128);
    v_tx_id VARCHAR(128);
    v_item JSONB;
BEGIN
    SELECT get_my_id() INTO v_user_id;
    IF v_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR, 'Unauthenticated user.'::VARCHAR;
        RETURN;
    END IF;

    -- 1. Check Election Status
    SELECT * INTO v_election FROM public.elections WHERE id = p_election_id;
    IF v_election.id IS NULL OR v_election.status != 'VOTING_OPEN' THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR, 'Election is not open for voting.'::VARCHAR;
        RETURN;
    END IF;

    -- 2. Verify Voter Eligibility
    SELECT (eligibility_status = 'ELIGIBLE') INTO v_eligible
    FROM public.election_voter_eligibility
    WHERE election_id = p_election_id AND student_id = v_user_id;

    IF v_eligible IS NOT NULL AND v_eligible = FALSE THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR, 'User is not eligible to vote in this election.'::VARCHAR;
        RETURN;
    END IF;

    -- 3. Prevent Double Voting
    SELECT EXISTS (
        SELECT 1 FROM public.voter_submissions
        WHERE election_id = p_election_id AND voter_id = v_user_id
    ) INTO v_existing_submission;

    IF v_existing_submission THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR, 'Voter has already cast a ballot for this election.'::VARCHAR;
        RETURN;
    END IF;

    -- Generate transaction reference and hash
    v_tx_id := 'ONL-' || gen_random_uuid()::text;
    v_receipt := encode(digest(v_user_id::text || p_election_id::text || clock_timestamp()::text, 'sha256'), 'hex');

    -- 4. Record Voter Submission (Ledger)
    INSERT INTO public.voter_submissions (
        election_id, voter_id, submission_mode, receipt_hash
    ) VALUES (
        p_election_id, v_user_id, 'online', v_receipt
    );

    -- 5. Record Anonymous Ballot
    INSERT INTO public.ballots (
        election_id, ballot_reference, voting_mode, transaction_id
    ) VALUES (
        p_election_id, 'BAL-' || encode(gen_random_uuid()::bytea, 'hex'), 'online', v_tx_id
    ) RETURNING id INTO v_ballot_id;

    -- 6. Insert Ballot Selections
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_selections)
    LOOP
        INSERT INTO public.ballot_selections (
            ballot_id, position_id, candidate_id, is_abstain
        ) VALUES (
            v_ballot_id,
            (v_item->>'position_id')::UUID,
            NULLIF(v_item->>'candidate_id', '')::UUID,
            COALESCE((v_item->>'is_abstain')::boolean, FALSE)
        );
    END LOOP;

    -- 7. Audit Log Entry
    INSERT INTO public.election_audit_logs (
        election_id, actor_id, action, target_type, target_id, metadata
    ) VALUES (
        p_election_id, v_user_id, 'VOTE_SUBMITTED_ONLINE', 'ballot', v_ballot_id, jsonb_build_object('receipt', v_receipt)
    );

    RETURN QUERY SELECT TRUE, v_receipt, 'Ballot successfully recorded.'::VARCHAR;
END;
$$;
