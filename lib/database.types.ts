// =====================================================================
// lib/database.types.ts — Types du schéma public Supabase
// Généré le 2026-05-20 par scripts/introspect-schema.mjs (introspection live).
// NE PAS éditer à la main — régénérer avec : node scripts/introspect-schema.mjs
// =====================================================================

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      accessibility_requests: {
        Row: {
          id: string;
          user_id: string;
          category: string;
          description: string;
          adaptations_requested: string | null;
          status: string;
          admin_response: string | null;
          referent_id: string | null;
          created_at: string;
          updated_at: string;
          resolved_at: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          category: string;
          description: string;
          adaptations_requested?: string | null;
          status?: string;
          admin_response?: string | null;
          referent_id?: string | null;
          created_at?: string;
          updated_at?: string;
          resolved_at?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          category?: string;
          description?: string;
          adaptations_requested?: string | null;
          status?: string;
          admin_response?: string | null;
          referent_id?: string | null;
          created_at?: string;
          updated_at?: string;
          resolved_at?: string | null;
        };
        Relationships: [];
      };
      acquisition_events: {
        Row: {
          id: string;
          visitor_id: string;
          user_id: string | null;
          utm_source: string | null;
          utm_medium: string | null;
          utm_campaign: string | null;
          utm_content: string | null;
          utm_term: string | null;
          referrer: string | null;
          landing_page: string;
          user_agent: string | null;
          ip_country: string | null;
          kind: string;
          occurred_at: string;
        };
        Insert: {
          id?: string;
          visitor_id: string;
          user_id?: string | null;
          utm_source?: string | null;
          utm_medium?: string | null;
          utm_campaign?: string | null;
          utm_content?: string | null;
          utm_term?: string | null;
          referrer?: string | null;
          landing_page: string;
          user_agent?: string | null;
          ip_country?: string | null;
          kind: string;
          occurred_at?: string;
        };
        Update: {
          id?: string;
          visitor_id?: string;
          user_id?: string | null;
          utm_source?: string | null;
          utm_medium?: string | null;
          utm_campaign?: string | null;
          utm_content?: string | null;
          utm_term?: string | null;
          referrer?: string | null;
          landing_page?: string;
          user_agent?: string | null;
          ip_country?: string | null;
          kind?: string;
          occurred_at?: string;
        };
        Relationships: [];
      };
      announcements: {
        Row: {
          id: string;
          title: string;
          body_md: string;
          audience: string;
          group_id: string | null;
          pinned: boolean;
          published_at: string | null;
          created_by: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          body_md?: string;
          audience?: string;
          group_id?: string | null;
          pinned?: boolean;
          published_at?: string | null;
          created_by?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          body_md?: string;
          audience?: string;
          group_id?: string | null;
          pinned?: boolean;
          published_at?: string | null;
          created_by?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      at_risk_students: {
        Row: {
          id: string | null;
          full_name: string | null;
          email: string | null;
          referent_id: string | null;
          group_id: string | null;
          last_attempt_at: string | null;
          last_lesson_at: string | null;
          avg_score: number | null;
          risk_flag: string | null;
        };
        Insert: {
          id?: string | null;
          full_name?: string | null;
          email?: string | null;
          referent_id?: string | null;
          group_id?: string | null;
          last_attempt_at?: string | null;
          last_lesson_at?: string | null;
          avg_score?: number | null;
          risk_flag?: string | null;
        };
        Update: {
          id?: string | null;
          full_name?: string | null;
          email?: string | null;
          referent_id?: string | null;
          group_id?: string | null;
          last_attempt_at?: string | null;
          last_lesson_at?: string | null;
          avg_score?: number | null;
          risk_flag?: string | null;
        };
        Relationships: [];
      };
      attendance_attendees: {
        Row: {
          session_id: string;
          user_id: string;
        };
        Insert: {
          session_id?: string;
          user_id?: string;
        };
        Update: {
          session_id?: string;
          user_id?: string;
        };
        Relationships: [];
      };
      attendance_sessions: {
        Row: {
          id: string;
          title: string;
          starts_at: string;
          ends_at: string;
          half_day: string;
          modality: string;
          location: string | null;
          trainer_id: string | null;
          trainer_signed_at: string | null;
          trainer_signature_name: string | null;
          topic: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          starts_at: string;
          ends_at: string;
          half_day: string;
          modality?: string;
          location?: string | null;
          trainer_id?: string | null;
          trainer_signed_at?: string | null;
          trainer_signature_name?: string | null;
          topic?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          starts_at?: string;
          ends_at?: string;
          half_day?: string;
          modality?: string;
          location?: string | null;
          trainer_id?: string | null;
          trainer_signed_at?: string | null;
          trainer_signature_name?: string | null;
          topic?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      attendance_signatures: {
        Row: {
          id: string;
          session_id: string;
          user_id: string;
          signed_at: string;
          signature_name: string;
          signature_ip: string | null;
          signature_ua: string | null;
          signature_hash: string | null;
        };
        Insert: {
          id?: string;
          session_id: string;
          user_id: string;
          signed_at?: string;
          signature_name: string;
          signature_ip?: string | null;
          signature_ua?: string | null;
          signature_hash?: string | null;
        };
        Update: {
          id?: string;
          session_id?: string;
          user_id?: string;
          signed_at?: string;
          signature_name?: string;
          signature_ip?: string | null;
          signature_ua?: string | null;
          signature_hash?: string | null;
        };
        Relationships: [];
      };
      attendance_summary: {
        Row: {
          id: string | null;
          title: string | null;
          starts_at: string | null;
          ends_at: string | null;
          half_day: string | null;
          expected: number | null;
          signed: number | null;
          trainer_signed: boolean | null;
        };
        Insert: {
          id?: string | null;
          title?: string | null;
          starts_at?: string | null;
          ends_at?: string | null;
          half_day?: string | null;
          expected?: number | null;
          signed?: number | null;
          trainer_signed?: boolean | null;
        };
        Update: {
          id?: string | null;
          title?: string | null;
          starts_at?: string | null;
          ends_at?: string | null;
          half_day?: string | null;
          expected?: number | null;
          signed?: number | null;
          trainer_signed?: boolean | null;
        };
        Relationships: [];
      };
      audit_log: {
        Row: {
          id: string;
          actor_id: string | null;
          actor_email: string | null;
          action: string;
          target_type: string | null;
          target_id: string | null;
          metadata: Json | null;
          ip_address: string | null;
          user_agent: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          actor_id?: string | null;
          actor_email?: string | null;
          action: string;
          target_type?: string | null;
          target_id?: string | null;
          metadata?: Json | null;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          actor_id?: string | null;
          actor_email?: string | null;
          action?: string;
          target_type?: string | null;
          target_id?: string | null;
          metadata?: Json | null;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      audit_logs: {
        Row: {
          id: string;
          actor_id: string | null;
          action: string;
          target_type: string | null;
          target_id: string | null;
          payload: Json | null;
          ip_address: string | null;
          user_agent: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          actor_id?: string | null;
          action: string;
          target_type?: string | null;
          target_id?: string | null;
          payload?: Json | null;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          actor_id?: string | null;
          action?: string;
          target_type?: string | null;
          target_id?: string | null;
          payload?: Json | null;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      badges: {
        Row: {
          id: string;
          code: string;
          name: string;
          description: string | null;
          icon: string;
          category: string;
          tier: string;
          criteria: Json;
          points: number;
          active: boolean;
          order: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          code: string;
          name: string;
          description?: string | null;
          icon?: string;
          category?: string;
          tier?: string;
          criteria: Json;
          points?: number;
          active?: boolean;
          order?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          code?: string;
          name?: string;
          description?: string | null;
          icon?: string;
          category?: string;
          tier?: string;
          criteria?: Json;
          points?: number;
          active?: boolean;
          order?: number;
          created_at?: string;
        };
        Relationships: [];
      };
      blocs: {
        Row: {
          id: number;
          code: string;
          title: string;
          description: string | null;
          order: number;
          created_at: string;
        };
        Insert: {
          id?: number;
          code: string;
          title: string;
          description?: string | null;
          order?: number;
          created_at?: string;
        };
        Update: {
          id?: number;
          code?: string;
          title?: string;
          description?: string | null;
          order?: number;
          created_at?: string;
        };
        Relationships: [];
      };
      certificates: {
        Row: {
          id: string;
          user_id: string;
          type: string;
          bloc_id: number | null;
          serial: string;
          issued_at: string;
          revoked_at: string | null;
          score_snapshot: Json | null;
          is_loyalty: boolean;
        };
        Insert: {
          id?: string;
          user_id: string;
          type: string;
          bloc_id?: number | null;
          serial: string;
          issued_at?: string;
          revoked_at?: string | null;
          score_snapshot?: Json | null;
          is_loyalty?: boolean;
        };
        Update: {
          id?: string;
          user_id?: string;
          type?: string;
          bloc_id?: number | null;
          serial?: string;
          issued_at?: string;
          revoked_at?: string | null;
          score_snapshot?: Json | null;
          is_loyalty?: boolean;
        };
        Relationships: [];
      };
      choices: {
        Row: {
          id: string;
          question_id: string;
          label: string;
          is_correct: boolean;
          order: number;
        };
        Insert: {
          id?: string;
          question_id: string;
          label: string;
          is_correct?: boolean;
          order?: number;
        };
        Update: {
          id?: string;
          question_id?: string;
          label?: string;
          is_correct?: boolean;
          order?: number;
        };
        Relationships: [];
      };
      coaching_notes: {
        Row: {
          id: string;
          user_id: string;
          trainer_id: string;
          body_md: string;
          visible_to_student: boolean;
          pinned: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          trainer_id: string;
          body_md: string;
          visible_to_student?: boolean;
          pinned?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          trainer_id?: string;
          body_md?: string;
          visible_to_student?: boolean;
          pinned?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      coaching_sessions: {
        Row: {
          id: string;
          user_id: string;
          trainer_id: string;
          scheduled_at: string;
          duration_min: number;
          mode: string;
          meeting_url: string | null;
          location: string | null;
          status: string;
          agenda: string | null;
          summary: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          trainer_id: string;
          scheduled_at: string;
          duration_min?: number;
          mode?: string;
          meeting_url?: string | null;
          location?: string | null;
          status?: string;
          agenda?: string | null;
          summary?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          trainer_id?: string;
          scheduled_at?: string;
          duration_min?: number;
          mode?: string;
          meeting_url?: string | null;
          location?: string | null;
          status?: string;
          agenda?: string | null;
          summary?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      conversation_participants: {
        Row: {
          conversation_id: string;
          user_id: string;
          role_in_conv: string;
          joined_at: string;
          last_read_at: string | null;
          pinned_at: string | null;
          muted: boolean;
          archived_at: string | null;
        };
        Insert: {
          conversation_id?: string;
          user_id?: string;
          role_in_conv?: string;
          joined_at?: string;
          last_read_at?: string | null;
          pinned_at?: string | null;
          muted?: boolean;
          archived_at?: string | null;
        };
        Update: {
          conversation_id?: string;
          user_id?: string;
          role_in_conv?: string;
          joined_at?: string;
          last_read_at?: string | null;
          pinned_at?: string | null;
          muted?: boolean;
          archived_at?: string | null;
        };
        Relationships: [];
      };
      conversations: {
        Row: {
          id: string;
          user_id: string | null;
          last_message_at: string;
          user_unread: number;
          admin_unread: number;
          created_at: string;
          kind: string;
          scope: string | null;
          group_id: string | null;
          title: string | null;
          created_by: string | null;
          archived_at: string | null;
          class_writable: boolean;
        };
        Insert: {
          id?: string;
          user_id?: string | null;
          last_message_at?: string;
          user_unread?: number;
          admin_unread?: number;
          created_at?: string;
          kind?: string;
          scope?: string | null;
          group_id?: string | null;
          title?: string | null;
          created_by?: string | null;
          archived_at?: string | null;
          class_writable?: boolean;
        };
        Update: {
          id?: string;
          user_id?: string | null;
          last_message_at?: string;
          user_unread?: number;
          admin_unread?: number;
          created_at?: string;
          kind?: string;
          scope?: string | null;
          group_id?: string | null;
          title?: string | null;
          created_by?: string | null;
          archived_at?: string | null;
          class_writable?: boolean;
        };
        Relationships: [];
      };
      crm_my_queue: {
        Row: {
          id: string | null;
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          phone: string | null;
          funding_kind: string | null;
          message: string | null;
          status: string | null;
          created_at: string | null;
          formation_slug: string | null;
          pack_slug: string | null;
          assigned_to_admin_id: string | null;
          next_followup_at: string | null;
          snoozed_until: string | null;
          source: string | null;
          tags: string[] | null;
          updated_at: string | null;
          is_snoozed: boolean | null;
          followup_due: boolean | null;
          notes_count: number | null;
        };
        Insert: {
          id?: string | null;
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          phone?: string | null;
          funding_kind?: string | null;
          message?: string | null;
          status?: string | null;
          created_at?: string | null;
          formation_slug?: string | null;
          pack_slug?: string | null;
          assigned_to_admin_id?: string | null;
          next_followup_at?: string | null;
          snoozed_until?: string | null;
          source?: string | null;
          tags?: string[] | null;
          updated_at?: string | null;
          is_snoozed?: boolean | null;
          followup_due?: boolean | null;
          notes_count?: number | null;
        };
        Update: {
          id?: string | null;
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          phone?: string | null;
          funding_kind?: string | null;
          message?: string | null;
          status?: string | null;
          created_at?: string | null;
          formation_slug?: string | null;
          pack_slug?: string | null;
          assigned_to_admin_id?: string | null;
          next_followup_at?: string | null;
          snoozed_until?: string | null;
          source?: string | null;
          tags?: string[] | null;
          updated_at?: string | null;
          is_snoozed?: boolean | null;
          followup_due?: boolean | null;
          notes_count?: number | null;
        };
        Relationships: [];
      };
      document_acceptances: {
        Row: {
          id: string;
          user_id: string;
          document_id: string;
          document_type: string;
          document_version: number;
          accepted_at: string;
          ip_address: string | null;
          user_agent: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          document_id: string;
          document_type: string;
          document_version: number;
          accepted_at?: string;
          ip_address?: string | null;
          user_agent?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          document_id?: string;
          document_type?: string;
          document_version?: number;
          accepted_at?: string;
          ip_address?: string | null;
          user_agent?: string | null;
        };
        Relationships: [];
      };
      enrollment_requests: {
        Row: {
          id: string;
          user_id: string | null;
          full_name: string;
          email: string;
          phone: string | null;
          funding_kind: string;
          message: string | null;
          status: string;
          created_at: string;
          formation_slug: string | null;
          pack_slug: string | null;
          assigned_to_admin_id: string | null;
          next_followup_at: string | null;
          snoozed_until: string | null;
          source: string | null;
          tags: string[];
          updated_at: string;
          adresse: string | null;
          code_postal: string | null;
          ville: string | null;
        };
        Insert: {
          id?: string;
          user_id?: string | null;
          full_name: string;
          email: string;
          phone?: string | null;
          funding_kind: string;
          message?: string | null;
          status?: string;
          created_at?: string;
          formation_slug?: string | null;
          pack_slug?: string | null;
          assigned_to_admin_id?: string | null;
          next_followup_at?: string | null;
          snoozed_until?: string | null;
          source?: string | null;
          tags: string[];
          updated_at?: string;
          adresse?: string | null;
          code_postal?: string | null;
          ville?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string | null;
          full_name?: string;
          email?: string;
          phone?: string | null;
          funding_kind?: string;
          message?: string | null;
          status?: string;
          created_at?: string;
          formation_slug?: string | null;
          pack_slug?: string | null;
          assigned_to_admin_id?: string | null;
          next_followup_at?: string | null;
          snoozed_until?: string | null;
          source?: string | null;
          tags?: string[];
          updated_at?: string;
          adresse?: string | null;
          code_postal?: string | null;
          ville?: string | null;
        };
        Relationships: [];
      };
      enrollments: {
        Row: {
          id: string;
          user_id: string;
          funder_id: string | null;
          funding_kind: string;
          session_label: string | null;
          start_date: string | null;
          end_date: string | null;
          total_amount_cents: number;
          paid_amount_cents: number;
          status: string;
          contract_url: string | null;
          convention_url: string | null;
          cpf_dossier_ref: string | null;
          created_at: string;
          updated_at: string;
          funder_signed_at: string | null;
          funder_signed_by_name: string | null;
          funder_signed_by_email: string | null;
          funder_signature_ip: string | null;
          funder_signature_hash: string | null;
          hours_total: number | null;
          modality: string | null;
          location: string | null;
          objectives: string | null;
          prerequisites: string | null;
          formation_slug: string | null;
          formation_id: string | null;
          pack: string;
          organization_id: string | null;
          seats_reserved: boolean;
        };
        Insert: {
          id?: string;
          user_id: string;
          funder_id?: string | null;
          funding_kind?: string;
          session_label?: string | null;
          start_date?: string | null;
          end_date?: string | null;
          total_amount_cents?: number;
          paid_amount_cents?: number;
          status?: string;
          contract_url?: string | null;
          convention_url?: string | null;
          cpf_dossier_ref?: string | null;
          created_at?: string;
          updated_at?: string;
          funder_signed_at?: string | null;
          funder_signed_by_name?: string | null;
          funder_signed_by_email?: string | null;
          funder_signature_ip?: string | null;
          funder_signature_hash?: string | null;
          hours_total?: number | null;
          modality?: string | null;
          location?: string | null;
          objectives?: string | null;
          prerequisites?: string | null;
          formation_slug?: string | null;
          formation_id?: string | null;
          pack?: string;
          organization_id?: string | null;
          seats_reserved?: boolean;
        };
        Update: {
          id?: string;
          user_id?: string;
          funder_id?: string | null;
          funding_kind?: string;
          session_label?: string | null;
          start_date?: string | null;
          end_date?: string | null;
          total_amount_cents?: number;
          paid_amount_cents?: number;
          status?: string;
          contract_url?: string | null;
          convention_url?: string | null;
          cpf_dossier_ref?: string | null;
          created_at?: string;
          updated_at?: string;
          funder_signed_at?: string | null;
          funder_signed_by_name?: string | null;
          funder_signed_by_email?: string | null;
          funder_signature_ip?: string | null;
          funder_signature_hash?: string | null;
          hours_total?: number | null;
          modality?: string | null;
          location?: string | null;
          objectives?: string | null;
          prerequisites?: string | null;
          formation_slug?: string | null;
          formation_id?: string | null;
          pack?: string;
          organization_id?: string | null;
          seats_reserved?: boolean;
        };
        Relationships: [];
      };
      formation_modules: {
        Row: {
          formation_id: string;
          module_id: string;
          display_order: number;
          required: boolean;
        };
        Insert: {
          formation_id?: string;
          module_id?: string;
          display_order?: number;
          required?: boolean;
        };
        Update: {
          formation_id?: string;
          module_id?: string;
          display_order?: number;
          required?: boolean;
        };
        Relationships: [];
      };
      formation_pack_prices: {
        Row: {
          id: string;
          formation_id: string;
          pack: string;
          price_cents: number;
          compare_at_cents: number | null;
          active: boolean;
          notes: string | null;
          created_at: string;
          updated_at: string;
          updated_by: string | null;
        };
        Insert: {
          id?: string;
          formation_id: string;
          pack: string;
          price_cents: number;
          compare_at_cents?: number | null;
          active?: boolean;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
          updated_by?: string | null;
        };
        Update: {
          id?: string;
          formation_id?: string;
          pack?: string;
          price_cents?: number;
          compare_at_cents?: number | null;
          active?: boolean;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
          updated_by?: string | null;
        };
        Relationships: [];
      };
      formation_quizzes: {
        Row: {
          formation_id: string;
          quiz_id: string;
          is_mock_exam: boolean;
          display_order: number;
        };
        Insert: {
          formation_id?: string;
          quiz_id?: string;
          is_mock_exam?: boolean;
          display_order?: number;
        };
        Update: {
          formation_id?: string;
          quiz_id?: string;
          is_mock_exam?: boolean;
          display_order?: number;
        };
        Relationships: [];
      };
      formation_settings: {
        Row: {
          id: boolean;
          organisme_nom: string;
          organisme_siret: string | null;
          organisme_num_da: string | null;
          organisme_adresse: string | null;
          organisme_email: string | null;
          organisme_telephone: string | null;
          organisme_responsable: string | null;
          formation_titre: string;
          formation_rncp: string;
          formation_duree_h: number;
          formation_public: string | null;
          formation_prerequis: string | null;
          formation_objectifs: string | null;
          formation_methodes: string | null;
          formation_evaluation: string | null;
          formation_handicap: string | null;
          formation_referent_handicap: string | null;
          formation_tarif: string | null;
          formation_delai_acces: string | null;
          indicateur_satisfaction: number | null;
          indicateur_reussite: number | null;
          updated_at: string;
          updated_by: string | null;
          formation_id: string;
        };
        Insert: {
          id?: boolean;
          organisme_nom?: string;
          organisme_siret?: string | null;
          organisme_num_da?: string | null;
          organisme_adresse?: string | null;
          organisme_email?: string | null;
          organisme_telephone?: string | null;
          organisme_responsable?: string | null;
          formation_titre?: string;
          formation_rncp?: string;
          formation_duree_h?: number;
          formation_public?: string | null;
          formation_prerequis?: string | null;
          formation_objectifs?: string | null;
          formation_methodes?: string | null;
          formation_evaluation?: string | null;
          formation_handicap?: string | null;
          formation_referent_handicap?: string | null;
          formation_tarif?: string | null;
          formation_delai_acces?: string | null;
          indicateur_satisfaction?: number | null;
          indicateur_reussite?: number | null;
          updated_at?: string;
          updated_by?: string | null;
          formation_id?: string;
        };
        Update: {
          id?: boolean;
          organisme_nom?: string;
          organisme_siret?: string | null;
          organisme_num_da?: string | null;
          organisme_adresse?: string | null;
          organisme_email?: string | null;
          organisme_telephone?: string | null;
          organisme_responsable?: string | null;
          formation_titre?: string;
          formation_rncp?: string;
          formation_duree_h?: number;
          formation_public?: string | null;
          formation_prerequis?: string | null;
          formation_objectifs?: string | null;
          formation_methodes?: string | null;
          formation_evaluation?: string | null;
          formation_handicap?: string | null;
          formation_referent_handicap?: string | null;
          formation_tarif?: string | null;
          formation_delai_acces?: string | null;
          indicateur_satisfaction?: number | null;
          indicateur_reussite?: number | null;
          updated_at?: string;
          updated_by?: string | null;
          formation_id?: string;
        };
        Relationships: [];
      };
      formations: {
        Row: {
          id: string;
          slug: string;
          code: string;
          title: string;
          tagline: string | null;
          category: string;
          level: number | null;
          rncp_code: string | null;
          duration: string | null;
          modality: string | null;
          active: boolean;
          display_order: number;
          accent_color: string | null;
          icon_name: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          slug: string;
          code: string;
          title: string;
          tagline?: string | null;
          category: string;
          level?: number | null;
          rncp_code?: string | null;
          duration?: string | null;
          modality?: string | null;
          active?: boolean;
          display_order?: number;
          accent_color?: string | null;
          icon_name?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          slug?: string;
          code?: string;
          title?: string;
          tagline?: string | null;
          category?: string;
          level?: number | null;
          rncp_code?: string | null;
          duration?: string | null;
          modality?: string | null;
          active?: boolean;
          display_order?: number;
          accent_color?: string | null;
          icon_name?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      funders: {
        Row: {
          id: string;
          name: string;
          kind: string;
          contact_email: string | null;
          contact_phone: string | null;
          siret: string | null;
          portal_user_id: string | null;
          notes: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          kind: string;
          contact_email?: string | null;
          contact_phone?: string | null;
          siret?: string | null;
          portal_user_id?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          kind?: string;
          contact_email?: string | null;
          contact_phone?: string | null;
          siret?: string | null;
          portal_user_id?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      glossary_terms: {
        Row: {
          id: string;
          term: string;
          definition_md: string;
          bloc_id: number | null;
          synonyms: string[];
          source: string | null;
          created_at: string;
          updated_at: string;
          formation_id: string | null;
        };
        Insert: {
          id?: string;
          term: string;
          definition_md: string;
          bloc_id?: number | null;
          synonyms: string[];
          source?: string | null;
          created_at?: string;
          updated_at?: string;
          formation_id?: string | null;
        };
        Update: {
          id?: string;
          term?: string;
          definition_md?: string;
          bloc_id?: number | null;
          synonyms?: string[];
          source?: string | null;
          created_at?: string;
          updated_at?: string;
          formation_id?: string | null;
        };
        Relationships: [];
      };
      groups: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          academic_year: string | null;
          color: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          description?: string | null;
          academic_year?: string | null;
          color?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          description?: string | null;
          academic_year?: string | null;
          color?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      inactivity_alerts: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          last_activity_at: string | null;
          days_inactive: number | null;
        };
        Insert: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          last_activity_at?: string | null;
          days_inactive?: number | null;
        };
        Update: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          last_activity_at?: string | null;
          days_inactive?: number | null;
        };
        Relationships: [];
      };
      inactivity_pings: {
        Row: {
          user_id: string;
          last_pinged_at: string;
          ping_count: number;
        };
        Insert: {
          user_id?: string;
          last_pinged_at?: string;
          ping_count?: number;
        };
        Update: {
          user_id?: string;
          last_pinged_at?: string;
          ping_count?: number;
        };
        Relationships: [];
      };
      lead_activities: {
        Row: {
          id: string;
          enrollment_request_id: string;
          author_id: string | null;
          kind: string;
          details: Json | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          enrollment_request_id: string;
          author_id?: string | null;
          kind: string;
          details?: Json | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          enrollment_request_id?: string;
          author_id?: string | null;
          kind?: string;
          details?: Json | null;
          created_at?: string;
        };
        Relationships: [];
      };
      lead_notes: {
        Row: {
          id: string;
          enrollment_request_id: string;
          author_id: string | null;
          kind: string;
          body: string;
          occurred_at: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          enrollment_request_id: string;
          author_id?: string | null;
          kind?: string;
          body: string;
          occurred_at?: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          enrollment_request_id?: string;
          author_id?: string | null;
          kind?: string;
          body?: string;
          occurred_at?: string;
          created_at?: string;
        };
        Relationships: [];
      };
      lesson_chunks: {
        Row: {
          id: string;
          lesson_id: string;
          chunk_index: number;
          content: string;
          token_count: number | null;
          embedding: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          lesson_id: string;
          chunk_index: number;
          content: string;
          token_count?: number | null;
          embedding?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          lesson_id?: string;
          chunk_index?: number;
          content?: string;
          token_count?: number | null;
          embedding?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      lesson_progress: {
        Row: {
          id: string;
          user_id: string;
          lesson_id: string;
          completed: boolean;
          completed_at: string | null;
          lesson_version_id: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          lesson_id: string;
          completed?: boolean;
          completed_at?: string | null;
          lesson_version_id?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          lesson_id?: string;
          completed?: boolean;
          completed_at?: string | null;
          lesson_version_id?: string | null;
        };
        Relationships: [];
      };
      lesson_resources: {
        Row: {
          id: string;
          lesson_id: string;
          kind: string;
          title: string;
          url: string;
          description: string | null;
          size_kb: number | null;
          order: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          lesson_id: string;
          kind: string;
          title: string;
          url: string;
          description?: string | null;
          size_kb?: number | null;
          order?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          lesson_id?: string;
          kind?: string;
          title?: string;
          url?: string;
          description?: string | null;
          size_kb?: number | null;
          order?: number;
          created_at?: string;
        };
        Relationships: [];
      };
      lesson_versions: {
        Row: {
          id: string;
          lesson_id: string;
          version: number;
          title: string | null;
          content_md: string | null;
          summary_md: string | null;
          video_url: string | null;
          edited_by: string | null;
          edited_at: string;
          change_note: string | null;
        };
        Insert: {
          id?: string;
          lesson_id: string;
          version: number;
          title?: string | null;
          content_md?: string | null;
          summary_md?: string | null;
          video_url?: string | null;
          edited_by?: string | null;
          edited_at?: string;
          change_note?: string | null;
        };
        Update: {
          id?: string;
          lesson_id?: string;
          version?: number;
          title?: string | null;
          content_md?: string | null;
          summary_md?: string | null;
          video_url?: string | null;
          edited_by?: string | null;
          edited_at?: string;
          change_note?: string | null;
        };
        Relationships: [];
      };
      lesson_views: {
        Row: {
          id: string;
          user_id: string;
          lesson_id: string;
          started_at: string;
          last_ping_at: string;
          duration_s: number;
          completed: boolean;
          formation_id: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          lesson_id: string;
          started_at?: string;
          last_ping_at?: string;
          duration_s?: number;
          completed?: boolean;
          formation_id?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          lesson_id?: string;
          started_at?: string;
          last_ping_at?: string;
          duration_s?: number;
          completed?: boolean;
          formation_id?: string | null;
        };
        Relationships: [];
      };
      lessons: {
        Row: {
          id: string;
          module_id: string;
          slug: string;
          title: string;
          content_md: string;
          summary_md: string | null;
          order: number;
          created_at: string;
          cover_url: string | null;
          video_url: string | null;
          current_version: number;
          duration_min: number;
        };
        Insert: {
          id?: string;
          module_id: string;
          slug: string;
          title: string;
          content_md: string;
          summary_md?: string | null;
          order?: number;
          created_at?: string;
          cover_url?: string | null;
          video_url?: string | null;
          current_version?: number;
          duration_min?: number;
        };
        Update: {
          id?: string;
          module_id?: string;
          slug?: string;
          title?: string;
          content_md?: string;
          summary_md?: string | null;
          order?: number;
          created_at?: string;
          cover_url?: string | null;
          video_url?: string | null;
          current_version?: number;
          duration_min?: number;
        };
        Relationships: [];
      };
      live_sessions: {
        Row: {
          id: string;
          title: string;
          description: string | null;
          formation_id: string;
          module_id: string | null;
          kind: string;
          start_at: string;
          end_at: string;
          location: string | null;
          meeting_provider: string | null;
          meeting_url: string | null;
          meeting_password: string | null;
          max_participants: number | null;
          trainer_id: string | null;
          status: string;
          notes_internal: string | null;
          created_at: string;
          updated_at: string;
          created_by: string | null;
        };
        Insert: {
          id?: string;
          title: string;
          description?: string | null;
          formation_id: string;
          module_id?: string | null;
          kind?: string;
          start_at: string;
          end_at: string;
          location?: string | null;
          meeting_provider?: string | null;
          meeting_url?: string | null;
          meeting_password?: string | null;
          max_participants?: number | null;
          trainer_id?: string | null;
          status?: string;
          notes_internal?: string | null;
          created_at?: string;
          updated_at?: string;
          created_by?: string | null;
        };
        Update: {
          id?: string;
          title?: string;
          description?: string | null;
          formation_id?: string;
          module_id?: string | null;
          kind?: string;
          start_at?: string;
          end_at?: string;
          location?: string | null;
          meeting_provider?: string | null;
          meeting_url?: string | null;
          meeting_password?: string | null;
          max_participants?: number | null;
          trainer_id?: string | null;
          status?: string;
          notes_internal?: string | null;
          created_at?: string;
          updated_at?: string;
          created_by?: string | null;
        };
        Relationships: [];
      };
      loyalty_events: {
        Row: {
          id: string;
          user_id: string;
          kind: string;
          details: Json | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          kind: string;
          details?: Json | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          kind?: string;
          details?: Json | null;
          created_at?: string;
        };
        Relationships: [];
      };
      message_attachments: {
        Row: {
          id: string;
          message_id: string;
          storage_path: string;
          mime_type: string;
          size_bytes: number;
          original_name: string;
          width: number | null;
          height: number | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          message_id: string;
          storage_path: string;
          mime_type: string;
          size_bytes: number;
          original_name: string;
          width?: number | null;
          height?: number | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          message_id?: string;
          storage_path?: string;
          mime_type?: string;
          size_bytes?: number;
          original_name?: string;
          width?: number | null;
          height?: number | null;
          created_at?: string;
        };
        Relationships: [];
      };
      message_reactions: {
        Row: {
          message_id: string;
          user_id: string;
          emoji: string;
          created_at: string;
        };
        Insert: {
          message_id?: string;
          user_id?: string;
          emoji?: string;
          created_at?: string;
        };
        Update: {
          message_id?: string;
          user_id?: string;
          emoji?: string;
          created_at?: string;
        };
        Relationships: [];
      };
      messages: {
        Row: {
          id: string;
          conversation_id: string;
          sender_id: string;
          sender_role: string;
          body: string;
          read_at: string | null;
          created_at: string;
          reply_to_id: string | null;
          edited_at: string | null;
          deleted_at: string | null;
        };
        Insert: {
          id?: string;
          conversation_id: string;
          sender_id: string;
          sender_role: string;
          body: string;
          read_at?: string | null;
          created_at?: string;
          reply_to_id?: string | null;
          edited_at?: string | null;
          deleted_at?: string | null;
        };
        Update: {
          id?: string;
          conversation_id?: string;
          sender_id?: string;
          sender_role?: string;
          body?: string;
          read_at?: string | null;
          created_at?: string;
          reply_to_id?: string | null;
          edited_at?: string | null;
          deleted_at?: string | null;
        };
        Relationships: [];
      };
      modules: {
        Row: {
          id: string;
          bloc_id: number;
          slug: string;
          title: string;
          summary: string | null;
          difficulty: string;
          duration_min: number;
          order: number;
          created_at: string;
          updated_at: string;
          cover_url: string | null;
          intro_video_path: string | null;
          intro_video_label: string | null;
          intro_video_duration_s: number | null;
          created_by: string | null;
          marketplace_status: string | null;
          marketplace_price_cents: number | null;
          marketplace_published_at: string | null;
          marketplace_reviewer_id: string | null;
          marketplace_review_notes: string | null;
        };
        Insert: {
          id?: string;
          bloc_id: number;
          slug: string;
          title: string;
          summary?: string | null;
          difficulty?: string;
          duration_min?: number;
          order?: number;
          created_at?: string;
          updated_at?: string;
          cover_url?: string | null;
          intro_video_path?: string | null;
          intro_video_label?: string | null;
          intro_video_duration_s?: number | null;
          created_by?: string | null;
          marketplace_status?: string | null;
          marketplace_price_cents?: number | null;
          marketplace_published_at?: string | null;
          marketplace_reviewer_id?: string | null;
          marketplace_review_notes?: string | null;
        };
        Update: {
          id?: string;
          bloc_id?: number;
          slug?: string;
          title?: string;
          summary?: string | null;
          difficulty?: string;
          duration_min?: number;
          order?: number;
          created_at?: string;
          updated_at?: string;
          cover_url?: string | null;
          intro_video_path?: string | null;
          intro_video_label?: string | null;
          intro_video_duration_s?: number | null;
          created_by?: string | null;
          marketplace_status?: string | null;
          marketplace_price_cents?: number | null;
          marketplace_published_at?: string | null;
          marketplace_reviewer_id?: string | null;
          marketplace_review_notes?: string | null;
        };
        Relationships: [];
      };
      notification_preferences: {
        Row: {
          user_id: string;
          in_app_disabled: string[];
          push_disabled: string[];
          email_disabled: string[];
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id?: string;
          in_app_disabled: string[];
          push_disabled: string[];
          email_disabled: string[];
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
          in_app_disabled?: string[];
          push_disabled?: string[];
          email_disabled?: string[];
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          body: string | null;
          created_at: string;
          type: string;
          link_url: string | null;
          read_at: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          title: string;
          body?: string | null;
          created_at?: string;
          type?: string;
          link_url?: string | null;
          read_at?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          title?: string;
          body?: string | null;
          created_at?: string;
          type?: string;
          link_url?: string | null;
          read_at?: string | null;
        };
        Relationships: [];
      };
      onboarding_documents: {
        Row: {
          id: string;
          type: string;
          title: string;
          version: number;
          content_md: string;
          published: boolean;
          created_at: string;
          updated_at: string;
          updated_by: string | null;
        };
        Insert: {
          id?: string;
          type: string;
          title: string;
          version?: number;
          content_md?: string;
          published?: boolean;
          created_at?: string;
          updated_at?: string;
          updated_by?: string | null;
        };
        Update: {
          id?: string;
          type?: string;
          title?: string;
          version?: number;
          content_md?: string;
          published?: boolean;
          created_at?: string;
          updated_at?: string;
          updated_by?: string | null;
        };
        Relationships: [];
      };
      organization_dashboard: {
        Row: {
          organization_id: string | null;
          name: string | null;
          slug: string | null;
          status: string | null;
          members_total: number | null;
          admins_count: number | null;
          learners_count: number | null;
          enrollments_total: number | null;
          enrollments_active: number | null;
          seats_pending: number | null;
          total_budget_cents: number | null;
          total_paid_cents: number | null;
        };
        Insert: {
          organization_id?: string | null;
          name?: string | null;
          slug?: string | null;
          status?: string | null;
          members_total?: number | null;
          admins_count?: number | null;
          learners_count?: number | null;
          enrollments_total?: number | null;
          enrollments_active?: number | null;
          seats_pending?: number | null;
          total_budget_cents?: number | null;
          total_paid_cents?: number | null;
        };
        Update: {
          organization_id?: string | null;
          name?: string | null;
          slug?: string | null;
          status?: string | null;
          members_total?: number | null;
          admins_count?: number | null;
          learners_count?: number | null;
          enrollments_total?: number | null;
          enrollments_active?: number | null;
          seats_pending?: number | null;
          total_budget_cents?: number | null;
          total_paid_cents?: number | null;
        };
        Relationships: [];
      };
      organization_members: {
        Row: {
          id: string;
          organization_id: string;
          user_id: string;
          role: string;
          invited_by: string | null;
          joined_at: string;
        };
        Insert: {
          id?: string;
          organization_id: string;
          user_id: string;
          role?: string;
          invited_by?: string | null;
          joined_at?: string;
        };
        Update: {
          id?: string;
          organization_id?: string;
          user_id?: string;
          role?: string;
          invited_by?: string | null;
          joined_at?: string;
        };
        Relationships: [];
      };
      organizations: {
        Row: {
          id: string;
          slug: string;
          name: string;
          legal_name: string | null;
          siret: string | null;
          vat_number: string | null;
          billing_email: string;
          billing_address: Json | null;
          logo_url: string | null;
          primary_color: string | null;
          contact_full_name: string | null;
          contact_phone: string | null;
          status: string;
          trial_ends_at: string | null;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          slug: string;
          name: string;
          legal_name?: string | null;
          siret?: string | null;
          vat_number?: string | null;
          billing_email: string;
          billing_address?: Json | null;
          logo_url?: string | null;
          primary_color?: string | null;
          contact_full_name?: string | null;
          contact_phone?: string | null;
          status?: string;
          trial_ends_at?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          slug?: string;
          name?: string;
          legal_name?: string | null;
          siret?: string | null;
          vat_number?: string | null;
          billing_email?: string;
          billing_address?: Json | null;
          logo_url?: string | null;
          primary_color?: string | null;
          contact_full_name?: string | null;
          contact_phone?: string | null;
          status?: string;
          trial_ends_at?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      payment_schedule: {
        Row: {
          id: string;
          enrollment_id: string;
          due_date: string;
          amount_cents: number;
          paid_at: string | null;
          paid_amount_cents: number | null;
          method: string | null;
          reference: string | null;
          notes: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          enrollment_id: string;
          due_date: string;
          amount_cents: number;
          paid_at?: string | null;
          paid_amount_cents?: number | null;
          method?: string | null;
          reference?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          enrollment_id?: string;
          due_date?: string;
          amount_cents?: number;
          paid_at?: string | null;
          paid_amount_cents?: number | null;
          method?: string | null;
          reference?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      payments_log: {
        Row: {
          id: string;
          stripe_session_id: string;
          user_id: string | null;
          email: string | null;
          plan_id: string | null;
          amount_cents: number;
          status: string;
          payload: Json | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          stripe_session_id: string;
          user_id?: string | null;
          email?: string | null;
          plan_id?: string | null;
          amount_cents?: number;
          status: string;
          payload?: Json | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          stripe_session_id?: string;
          user_id?: string | null;
          email?: string | null;
          plan_id?: string | null;
          amount_cents?: number;
          status?: string;
          payload?: Json | null;
          created_at?: string;
        };
        Relationships: [];
      };
      pinned_messages: {
        Row: {
          conversation_id: string;
          message_id: string;
          pinned_by: string;
          pinned_at: string;
        };
        Insert: {
          conversation_id?: string;
          message_id?: string;
          pinned_by: string;
          pinned_at?: string;
        };
        Update: {
          conversation_id?: string;
          message_id?: string;
          pinned_by?: string;
          pinned_at?: string;
        };
        Relationships: [];
      };
      placement_questions: {
        Row: {
          id: string;
          bloc_id: number;
          prompt: string;
          choices: Json;
          correct_index: number;
          difficulty: string;
          order: number;
          active: boolean;
          created_at: string;
          qtype: string;
          image_url: string | null;
          expected_answer: string | null;
          formation_id: string | null;
        };
        Insert: {
          id?: string;
          bloc_id: number;
          prompt: string;
          choices: Json;
          correct_index: number;
          difficulty?: string;
          order?: number;
          active?: boolean;
          created_at?: string;
          qtype?: string;
          image_url?: string | null;
          expected_answer?: string | null;
          formation_id?: string | null;
        };
        Update: {
          id?: string;
          bloc_id?: number;
          prompt?: string;
          choices?: Json;
          correct_index?: number;
          difficulty?: string;
          order?: number;
          active?: boolean;
          created_at?: string;
          qtype?: string;
          image_url?: string | null;
          expected_answer?: string | null;
          formation_id?: string | null;
        };
        Relationships: [];
      };
      placement_results: {
        Row: {
          user_id: string;
          scores: Json;
          level_per_bloc: Json;
          recommended_bloc_id: number | null;
          answers: Json | null;
          duration_s: number | null;
          taken_at: string;
        };
        Insert: {
          user_id?: string;
          scores: Json;
          level_per_bloc: Json;
          recommended_bloc_id?: number | null;
          answers?: Json | null;
          duration_s?: number | null;
          taken_at?: string;
        };
        Update: {
          user_id?: string;
          scores?: Json;
          level_per_bloc?: Json;
          recommended_bloc_id?: number | null;
          answers?: Json | null;
          duration_s?: number | null;
          taken_at?: string;
        };
        Relationships: [];
      };
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string | null;
          role: string;
          level: string;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
          group_id: string | null;
          disabled: boolean;
          phone: string | null;
          notes: string | null;
          last_sign_in_at: string | null;
          total_session_s: number;
          session_count: number;
          onboarding_completed_at: string | null;
          placement_completed_at: string | null;
          referent_id: string | null;
          a11y_font_scale: number;
          a11y_dyslexia_font: boolean;
          a11y_high_contrast: boolean;
          a11y_reduced_motion: boolean;
          a11y_underline_links: boolean;
          a11y_notes: string | null;
          a11y_rqth: boolean;
          date_naissance: string | null;
          adresse: string | null;
          code_postal: string | null;
          ville: string | null;
          pays: string | null;
          trainer_id: string | null;
          entry_date: string | null;
          dossier_status: string | null;
          current_formation_id: string | null;
          leaderboard_opt_out: boolean;
        };
        Insert: {
          id?: string;
          email: string;
          full_name?: string | null;
          role?: string;
          level?: string;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
          group_id?: string | null;
          disabled?: boolean;
          phone?: string | null;
          notes?: string | null;
          last_sign_in_at?: string | null;
          total_session_s?: number;
          session_count?: number;
          onboarding_completed_at?: string | null;
          placement_completed_at?: string | null;
          referent_id?: string | null;
          a11y_font_scale?: number;
          a11y_dyslexia_font?: boolean;
          a11y_high_contrast?: boolean;
          a11y_reduced_motion?: boolean;
          a11y_underline_links?: boolean;
          a11y_notes?: string | null;
          a11y_rqth?: boolean;
          date_naissance?: string | null;
          adresse?: string | null;
          code_postal?: string | null;
          ville?: string | null;
          pays?: string | null;
          trainer_id?: string | null;
          entry_date?: string | null;
          dossier_status?: string | null;
          current_formation_id?: string | null;
          leaderboard_opt_out?: boolean;
        };
        Update: {
          id?: string;
          email?: string;
          full_name?: string | null;
          role?: string;
          level?: string;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
          group_id?: string | null;
          disabled?: boolean;
          phone?: string | null;
          notes?: string | null;
          last_sign_in_at?: string | null;
          total_session_s?: number;
          session_count?: number;
          onboarding_completed_at?: string | null;
          placement_completed_at?: string | null;
          referent_id?: string | null;
          a11y_font_scale?: number;
          a11y_dyslexia_font?: boolean;
          a11y_high_contrast?: boolean;
          a11y_reduced_motion?: boolean;
          a11y_underline_links?: boolean;
          a11y_notes?: string | null;
          a11y_rqth?: boolean;
          date_naissance?: string | null;
          adresse?: string | null;
          code_postal?: string | null;
          ville?: string | null;
          pays?: string | null;
          trainer_id?: string | null;
          entry_date?: string | null;
          dossier_status?: string | null;
          current_formation_id?: string | null;
          leaderboard_opt_out?: boolean;
        };
        Relationships: [];
      };
      push_subscriptions: {
        Row: {
          id: string;
          user_id: string;
          endpoint: string;
          p256dh: string;
          auth: string;
          user_agent: string | null;
          created_at: string;
          last_used_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          endpoint: string;
          p256dh: string;
          auth: string;
          user_agent?: string | null;
          created_at?: string;
          last_used_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          endpoint?: string;
          p256dh?: string;
          auth?: string;
          user_agent?: string | null;
          created_at?: string;
          last_used_at?: string;
        };
        Relationships: [];
      };
      qr_responses: {
        Row: {
          id: string;
          attempt_id: string;
          question_id: string;
          student_answer: string | null;
          trainer_score: number | null;
          max_score: number;
          trainer_comment: string | null;
          graded_by: string | null;
          graded_at: string | null;
          submitted_at: string;
          ai_score: number | null;
          ai_feedback_md: string | null;
          ai_criteria: Json | null;
          ai_confidence: string | null;
          ai_concerns: string | null;
          ai_model: string | null;
          ai_tokens_in: number | null;
          ai_tokens_out: number | null;
          ai_cost_cents: number | null;
          ai_graded_at: string | null;
        };
        Insert: {
          id?: string;
          attempt_id: string;
          question_id: string;
          student_answer?: string | null;
          trainer_score?: number | null;
          max_score?: number;
          trainer_comment?: string | null;
          graded_by?: string | null;
          graded_at?: string | null;
          submitted_at?: string;
          ai_score?: number | null;
          ai_feedback_md?: string | null;
          ai_criteria?: Json | null;
          ai_confidence?: string | null;
          ai_concerns?: string | null;
          ai_model?: string | null;
          ai_tokens_in?: number | null;
          ai_tokens_out?: number | null;
          ai_cost_cents?: number | null;
          ai_graded_at?: string | null;
        };
        Update: {
          id?: string;
          attempt_id?: string;
          question_id?: string;
          student_answer?: string | null;
          trainer_score?: number | null;
          max_score?: number;
          trainer_comment?: string | null;
          graded_by?: string | null;
          graded_at?: string | null;
          submitted_at?: string;
          ai_score?: number | null;
          ai_feedback_md?: string | null;
          ai_criteria?: Json | null;
          ai_confidence?: string | null;
          ai_concerns?: string | null;
          ai_model?: string | null;
          ai_tokens_in?: number | null;
          ai_tokens_out?: number | null;
          ai_cost_cents?: number | null;
          ai_graded_at?: string | null;
        };
        Relationships: [];
      };
      question_attachments: {
        Row: {
          id: string;
          question_id: string;
          storage_path: string;
          file_name: string;
          mime_type: string;
          size_bytes: number | null;
          kind: string;
          label: string | null;
          display_order: number;
          created_at: string;
          created_by: string | null;
        };
        Insert: {
          id?: string;
          question_id: string;
          storage_path: string;
          file_name: string;
          mime_type: string;
          size_bytes?: number | null;
          kind?: string;
          label?: string | null;
          display_order?: number;
          created_at?: string;
          created_by?: string | null;
        };
        Update: {
          id?: string;
          question_id?: string;
          storage_path?: string;
          file_name?: string;
          mime_type?: string;
          size_bytes?: number | null;
          kind?: string;
          label?: string | null;
          display_order?: number;
          created_at?: string;
          created_by?: string | null;
        };
        Relationships: [];
      };
      question_bank: {
        Row: {
          id: string;
          formation_id: string | null;
          module_id: string | null;
          type: string;
          statement: string;
          choices: Json | null;
          expected_answer: string | null;
          scoring_grid: string | null;
          max_score: number;
          difficulty: string;
          tags: string[];
          explanation: string | null;
          source_ref: string | null;
          reformulated_at: string | null;
          reformulated_by: string | null;
          active: boolean;
          created_at: string;
          updated_at: string;
          created_by: string | null;
          import_id: string | null;
          lesson_id: string | null;
          annex_pages: number[];
          annex_labels: string[];
        };
        Insert: {
          id?: string;
          formation_id?: string | null;
          module_id?: string | null;
          type: string;
          statement: string;
          choices?: Json | null;
          expected_answer?: string | null;
          scoring_grid?: string | null;
          max_score?: number;
          difficulty?: string;
          tags: string[];
          explanation?: string | null;
          source_ref?: string | null;
          reformulated_at?: string | null;
          reformulated_by?: string | null;
          active?: boolean;
          created_at?: string;
          updated_at?: string;
          created_by?: string | null;
          import_id?: string | null;
          lesson_id?: string | null;
          annex_pages: number[];
          annex_labels: string[];
        };
        Update: {
          id?: string;
          formation_id?: string | null;
          module_id?: string | null;
          type?: string;
          statement?: string;
          choices?: Json | null;
          expected_answer?: string | null;
          scoring_grid?: string | null;
          max_score?: number;
          difficulty?: string;
          tags?: string[];
          explanation?: string | null;
          source_ref?: string | null;
          reformulated_at?: string | null;
          reformulated_by?: string | null;
          active?: boolean;
          created_at?: string;
          updated_at?: string;
          created_by?: string | null;
          import_id?: string | null;
          lesson_id?: string | null;
          annex_pages?: number[];
          annex_labels?: string[];
        };
        Relationships: [];
      };
      question_imports: {
        Row: {
          id: string;
          file_name: string;
          file_size_bytes: number | null;
          file_kind: string;
          formation_id: string | null;
          module_id: string | null;
          expected_type: string;
          status: string;
          questions_count: number;
          errors_count: number;
          raw_text: string | null;
          notes: string | null;
          created_at: string;
          completed_at: string | null;
          created_by: string | null;
          pdf_storage_path: string | null;
          annex_pages: number[];
          annex_labels: string[];
        };
        Insert: {
          id?: string;
          file_name: string;
          file_size_bytes?: number | null;
          file_kind?: string;
          formation_id?: string | null;
          module_id?: string | null;
          expected_type?: string;
          status?: string;
          questions_count?: number;
          errors_count?: number;
          raw_text?: string | null;
          notes?: string | null;
          created_at?: string;
          completed_at?: string | null;
          created_by?: string | null;
          pdf_storage_path?: string | null;
          annex_pages: number[];
          annex_labels: string[];
        };
        Update: {
          id?: string;
          file_name?: string;
          file_size_bytes?: number | null;
          file_kind?: string;
          formation_id?: string | null;
          module_id?: string | null;
          expected_type?: string;
          status?: string;
          questions_count?: number;
          errors_count?: number;
          raw_text?: string | null;
          notes?: string | null;
          created_at?: string;
          completed_at?: string | null;
          created_by?: string | null;
          pdf_storage_path?: string | null;
          annex_pages?: number[];
          annex_labels?: string[];
        };
        Relationships: [];
      };
      questions: {
        Row: {
          id: string;
          quiz_id: string;
          statement: string;
          explanation: string | null;
          order: number;
          image_url: string | null;
        };
        Insert: {
          id?: string;
          quiz_id: string;
          statement: string;
          explanation?: string | null;
          order?: number;
          image_url?: string | null;
        };
        Update: {
          id?: string;
          quiz_id?: string;
          statement?: string;
          explanation?: string | null;
          order?: number;
          image_url?: string | null;
        };
        Relationships: [];
      };
      quiz_attempts: {
        Row: {
          id: string;
          user_id: string;
          quiz_id: string;
          score: number | null;
          total: number | null;
          percentage: number | null;
          passed: boolean | null;
          duration_s: number | null;
          answers: Json | null;
          started_at: string;
          finished_at: string | null;
          focus_loss_count: number;
          mode: string;
          flagged_questions: string[];
          status: string;
          qcm_score: number | null;
          qr_score: number | null;
          final_percentage: number | null;
          final_passed: boolean | null;
          graded_at: string | null;
          graded_by: string | null;
          trainer_global_comment: string | null;
          formation_id: string;
          client_attempt_id: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          quiz_id: string;
          score?: number | null;
          total?: number | null;
          percentage?: number | null;
          passed?: boolean | null;
          duration_s?: number | null;
          answers?: Json | null;
          started_at?: string;
          finished_at?: string | null;
          focus_loss_count?: number;
          mode?: string;
          flagged_questions: string[];
          status?: string;
          qcm_score?: number | null;
          qr_score?: number | null;
          final_percentage?: number | null;
          final_passed?: boolean | null;
          graded_at?: string | null;
          graded_by?: string | null;
          trainer_global_comment?: string | null;
          formation_id: string;
          client_attempt_id?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          quiz_id?: string;
          score?: number | null;
          total?: number | null;
          percentage?: number | null;
          passed?: boolean | null;
          duration_s?: number | null;
          answers?: Json | null;
          started_at?: string;
          finished_at?: string | null;
          focus_loss_count?: number;
          mode?: string;
          flagged_questions?: string[];
          status?: string;
          qcm_score?: number | null;
          qr_score?: number | null;
          final_percentage?: number | null;
          final_passed?: boolean | null;
          graded_at?: string | null;
          graded_by?: string | null;
          trainer_global_comment?: string | null;
          formation_id?: string;
          client_attempt_id?: string | null;
        };
        Relationships: [];
      };
      quiz_question_bank: {
        Row: {
          quiz_id: string;
          question_id: string;
          display_order: number;
        };
        Insert: {
          quiz_id?: string;
          question_id?: string;
          display_order?: number;
        };
        Update: {
          quiz_id?: string;
          question_id?: string;
          display_order?: number;
        };
        Relationships: [];
      };
      quizzes: {
        Row: {
          id: string;
          module_id: string | null;
          title: string;
          description: string | null;
          type: string;
          time_limit_s: number | null;
          pass_threshold: number;
          created_at: string;
          timer_enabled: boolean;
          is_mock_exam: boolean;
          max_attempts: number | null;
          retake_delay_hours: number;
          shuffle_questions: boolean;
          shuffle_choices: boolean;
          require_fullscreen: boolean;
          show_explanations_mode: string;
          generation_mode: string;
          bank_filters: Json | null;
          requires_manual_grading: boolean;
        };
        Insert: {
          id?: string;
          module_id?: string | null;
          title: string;
          description?: string | null;
          type?: string;
          time_limit_s?: number | null;
          pass_threshold?: number;
          created_at?: string;
          timer_enabled?: boolean;
          is_mock_exam?: boolean;
          max_attempts?: number | null;
          retake_delay_hours?: number;
          shuffle_questions?: boolean;
          shuffle_choices?: boolean;
          require_fullscreen?: boolean;
          show_explanations_mode?: string;
          generation_mode?: string;
          bank_filters?: Json | null;
          requires_manual_grading?: boolean;
        };
        Update: {
          id?: string;
          module_id?: string | null;
          title?: string;
          description?: string | null;
          type?: string;
          time_limit_s?: number | null;
          pass_threshold?: number;
          created_at?: string;
          timer_enabled?: boolean;
          is_mock_exam?: boolean;
          max_attempts?: number | null;
          retake_delay_hours?: number;
          shuffle_questions?: boolean;
          shuffle_choices?: boolean;
          require_fullscreen?: boolean;
          show_explanations_mode?: string;
          generation_mode?: string;
          bank_filters?: Json | null;
          requires_manual_grading?: boolean;
        };
        Relationships: [];
      };
      referral_codes: {
        Row: {
          user_id: string;
          code: string;
          created_at: string;
          active: boolean;
        };
        Insert: {
          user_id?: string;
          code: string;
          created_at?: string;
          active?: boolean;
        };
        Update: {
          user_id?: string;
          code?: string;
          created_at?: string;
          active?: boolean;
        };
        Relationships: [];
      };
      referrals: {
        Row: {
          id: string;
          referrer_id: string;
          referred_user_id: string;
          code_used: string;
          status: string;
          enrollment_id: string | null;
          reward_cents: number | null;
          rewarded_at: string | null;
          rewarded_by: string | null;
          rejection_reason: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          referrer_id: string;
          referred_user_id: string;
          code_used: string;
          status: string;
          enrollment_id?: string | null;
          reward_cents?: number | null;
          rewarded_at?: string | null;
          rewarded_by?: string | null;
          rejection_reason?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          referrer_id?: string;
          referred_user_id?: string;
          code_used?: string;
          status?: string;
          enrollment_id?: string | null;
          reward_cents?: number | null;
          rewarded_at?: string | null;
          rewarded_by?: string | null;
          rejection_reason?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      satisfaction_surveys: {
        Row: {
          id: string;
          user_id: string;
          type: string;
          note_globale: number | null;
          note_contenu: number | null;
          note_pedagogie: number | null;
          note_plateforme: number | null;
          note_accompagnement: number | null;
          points_forts: string | null;
          points_ameliorer: string | null;
          recommandation: number | null;
          situation_pro: string | null;
          situation_detail: string | null;
          submitted_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          type: string;
          note_globale?: number | null;
          note_contenu?: number | null;
          note_pedagogie?: number | null;
          note_plateforme?: number | null;
          note_accompagnement?: number | null;
          points_forts?: string | null;
          points_ameliorer?: string | null;
          recommandation?: number | null;
          situation_pro?: string | null;
          situation_detail?: string | null;
          submitted_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          type?: string;
          note_globale?: number | null;
          note_contenu?: number | null;
          note_pedagogie?: number | null;
          note_plateforme?: number | null;
          note_accompagnement?: number | null;
          points_forts?: string | null;
          points_ameliorer?: string | null;
          recommandation?: number | null;
          situation_pro?: string | null;
          situation_detail?: string | null;
          submitted_at?: string;
        };
        Relationships: [];
      };
      search_logs: {
        Row: {
          id: string;
          user_id: string | null;
          query: string;
          query_norm: string | null;
          results_count: number;
          kind_filter: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id?: string | null;
          query: string;
          query_norm?: string | null;
          results_count?: number;
          kind_filter?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string | null;
          query?: string;
          query_norm?: string | null;
          results_count?: number;
          kind_filter?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      session_attendance: {
        Row: {
          session_id: string;
          user_id: string;
          signed_at: string;
          method: string;
          ip_address: string | null;
          user_agent: string | null;
          signature_storage_path: string | null;
          validated_by: string | null;
          validated_at: string | null;
          notes: string | null;
        };
        Insert: {
          session_id?: string;
          user_id?: string;
          signed_at?: string;
          method?: string;
          ip_address?: string | null;
          user_agent?: string | null;
          signature_storage_path?: string | null;
          validated_by?: string | null;
          validated_at?: string | null;
          notes?: string | null;
        };
        Update: {
          session_id?: string;
          user_id?: string;
          signed_at?: string;
          method?: string;
          ip_address?: string | null;
          user_agent?: string | null;
          signature_storage_path?: string | null;
          validated_by?: string | null;
          validated_at?: string | null;
          notes?: string | null;
        };
        Relationships: [];
      };
      session_enrollments: {
        Row: {
          session_id: string;
          user_id: string;
          status: string;
          registered_at: string;
          cancelled_at: string | null;
          cancellation_reason: string | null;
        };
        Insert: {
          session_id?: string;
          user_id?: string;
          status?: string;
          registered_at?: string;
          cancelled_at?: string | null;
          cancellation_reason?: string | null;
        };
        Update: {
          session_id?: string;
          user_id?: string;
          status?: string;
          registered_at?: string;
          cancelled_at?: string | null;
          cancellation_reason?: string | null;
        };
        Relationships: [];
      };
      trainer_assignments: {
        Row: {
          id: string;
          trainer_id: string;
          student_id: string;
          role: string;
          formation_slug: string | null;
          assigned_at: string;
        };
        Insert: {
          id?: string;
          trainer_id: string;
          student_id: string;
          role?: string;
          formation_slug?: string | null;
          assigned_at?: string;
        };
        Update: {
          id?: string;
          trainer_id?: string;
          student_id?: string;
          role?: string;
          formation_slug?: string | null;
          assigned_at?: string;
        };
        Relationships: [];
      };
      trainer_formations: {
        Row: {
          id: string;
          trainer_id: string;
          formation_id: string;
          can_grade: boolean;
          can_edit_content: boolean;
          is_lead: boolean;
          granted_at: string;
          granted_by: string | null;
        };
        Insert: {
          id?: string;
          trainer_id: string;
          formation_id: string;
          can_grade?: boolean;
          can_edit_content?: boolean;
          is_lead?: boolean;
          granted_at?: string;
          granted_by?: string | null;
        };
        Update: {
          id?: string;
          trainer_id?: string;
          formation_id?: string;
          can_grade?: boolean;
          can_edit_content?: boolean;
          is_lead?: boolean;
          granted_at?: string;
          granted_by?: string | null;
        };
        Relationships: [];
      };
      trainer_payouts: {
        Row: {
          user_id: string;
          stripe_connect_account_id: string | null;
          stripe_onboarding_complete: boolean | null;
          stripe_charges_enabled: boolean | null;
          stripe_payouts_enabled: boolean | null;
          kyc_status: string | null;
          kyc_updated_at: string | null;
          revenue_share_pct: number | null;
          contract_signed_at: string | null;
          contract_url: string | null;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id?: string;
          stripe_connect_account_id?: string | null;
          stripe_onboarding_complete?: boolean | null;
          stripe_charges_enabled?: boolean | null;
          stripe_payouts_enabled?: boolean | null;
          kyc_status?: string | null;
          kyc_updated_at?: string | null;
          revenue_share_pct?: number | null;
          contract_signed_at?: string | null;
          contract_url?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
          stripe_connect_account_id?: string | null;
          stripe_onboarding_complete?: boolean | null;
          stripe_charges_enabled?: boolean | null;
          stripe_payouts_enabled?: boolean | null;
          kyc_status?: string | null;
          kyc_updated_at?: string | null;
          revenue_share_pct?: number | null;
          contract_signed_at?: string | null;
          contract_url?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      trainer_revenue_events: {
        Row: {
          id: string;
          trainer_user_id: string;
          module_id: string | null;
          enrollment_id: string | null;
          gross_amount_cents: number;
          platform_fee_cents: number;
          trainer_share_cents: number;
          stripe_session_id: string | null;
          stripe_transfer_id: string | null;
          status: string;
          transferred_at: string | null;
          notes: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          trainer_user_id: string;
          module_id?: string | null;
          enrollment_id?: string | null;
          gross_amount_cents: number;
          platform_fee_cents: number;
          trainer_share_cents: number;
          stripe_session_id?: string | null;
          stripe_transfer_id?: string | null;
          status?: string;
          transferred_at?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          trainer_user_id?: string;
          module_id?: string | null;
          enrollment_id?: string | null;
          gross_amount_cents?: number;
          platform_fee_cents?: number;
          trainer_share_cents?: number;
          stripe_session_id?: string | null;
          stripe_transfer_id?: string | null;
          status?: string;
          transferred_at?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
      tutor_conversations: {
        Row: {
          id: string;
          user_id: string;
          title: string | null;
          context_module_id: string | null;
          context_formation_slug: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          title?: string | null;
          context_module_id?: string | null;
          context_formation_slug?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          title?: string | null;
          context_module_id?: string | null;
          context_formation_slug?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      tutor_messages: {
        Row: {
          id: string;
          conversation_id: string;
          role: string;
          content: string;
          citations: Json | null;
          tokens_in: number | null;
          tokens_out: number | null;
          cost_cents: number | null;
          moderation_passed: boolean | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          conversation_id: string;
          role: string;
          content: string;
          citations?: Json | null;
          tokens_in?: number | null;
          tokens_out?: number | null;
          cost_cents?: number | null;
          moderation_passed?: boolean | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          conversation_id?: string;
          role?: string;
          content?: string;
          citations?: Json | null;
          tokens_in?: number | null;
          tokens_out?: number | null;
          cost_cents?: number | null;
          moderation_passed?: boolean | null;
          created_at?: string;
        };
        Relationships: [];
      };
      tutor_quotas: {
        Row: {
          user_id: string;
          month: string;
          messages_count: number;
          cost_cents: number;
          updated_at: string;
        };
        Insert: {
          user_id?: string;
          month?: string;
          messages_count?: number;
          cost_cents?: number;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
          month?: string;
          messages_count?: number;
          cost_cents?: number;
          updated_at?: string;
        };
        Relationships: [];
      };
      user_activity_summary: {
        Row: {
          id: string | null;
          email: string | null;
          full_name: string | null;
          group_id: string | null;
          disabled: boolean | null;
          last_sign_in_at: string | null;
          total_session_s: number | null;
          session_count: number | null;
          quiz_attempts_count: number | null;
          lessons_completed_count: number | null;
          avg_score: number | null;
        };
        Insert: {
          id?: string | null;
          email?: string | null;
          full_name?: string | null;
          group_id?: string | null;
          disabled?: boolean | null;
          last_sign_in_at?: string | null;
          total_session_s?: number | null;
          session_count?: number | null;
          quiz_attempts_count?: number | null;
          lessons_completed_count?: number | null;
          avg_score?: number | null;
        };
        Update: {
          id?: string | null;
          email?: string | null;
          full_name?: string | null;
          group_id?: string | null;
          disabled?: boolean | null;
          last_sign_in_at?: string | null;
          total_session_s?: number | null;
          session_count?: number | null;
          quiz_attempts_count?: number | null;
          lessons_completed_count?: number | null;
          avg_score?: number | null;
        };
        Relationships: [];
      };
      user_badges: {
        Row: {
          id: string;
          user_id: string;
          badge_id: string;
          earned_at: string;
          context: Json | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          badge_id: string;
          earned_at?: string;
          context?: Json | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          badge_id?: string;
          earned_at?: string;
          context?: Json | null;
        };
        Relationships: [];
      };
      user_credits: {
        Row: {
          id: string;
          user_id: string;
          amount_cents: number;
          kind: string;
          ref_id: string | null;
          description: string | null;
          created_at: string;
          created_by: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          amount_cents: number;
          kind: string;
          ref_id?: string | null;
          description?: string | null;
          created_at?: string;
          created_by?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          amount_cents?: number;
          kind?: string;
          ref_id?: string | null;
          description?: string | null;
          created_at?: string;
          created_by?: string | null;
        };
        Relationships: [];
      };
      user_gamification: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          total_xp: number | null;
          level: number | null;
          active_days: number | null;
          last_xp_at: string | null;
        };
        Insert: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          total_xp?: number | null;
          level?: number | null;
          active_days?: number | null;
          last_xp_at?: string | null;
        };
        Update: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          total_xp?: number | null;
          level?: number | null;
          active_days?: number | null;
          last_xp_at?: string | null;
        };
        Relationships: [];
      };
      user_last_activity: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          last_activity_at: string | null;
          is_active_enrollment: boolean | null;
        };
        Insert: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          last_activity_at?: string | null;
          is_active_enrollment?: boolean | null;
        };
        Update: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          last_activity_at?: string | null;
          is_active_enrollment?: boolean | null;
        };
        Relationships: [];
      };
      user_loyalty_status: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          paid_enrollments: number | null;
          tier: string | null;
          enrollments_to_next_tier: number | null;
          next_discount_pct: number | null;
          final_certificates_count: number | null;
        };
        Insert: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          paid_enrollments?: number | null;
          tier?: string | null;
          enrollments_to_next_tier?: number | null;
          next_discount_pct?: number | null;
          final_certificates_count?: number | null;
        };
        Update: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          paid_enrollments?: number | null;
          tier?: string | null;
          enrollments_to_next_tier?: number | null;
          next_discount_pct?: number | null;
          final_certificates_count?: number | null;
        };
        Relationships: [];
      };
      user_onboarding_status: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          onboarding_completed_at: string | null;
          required_docs: number | null;
          accepted_docs: number | null;
        };
        Insert: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          onboarding_completed_at?: string | null;
          required_docs?: number | null;
          accepted_docs?: number | null;
        };
        Update: {
          user_id?: string | null;
          full_name?: string | null;
          email?: string | null;
          onboarding_completed_at?: string | null;
          required_docs?: number | null;
          accepted_docs?: number | null;
        };
        Relationships: [];
      };
      user_sessions: {
        Row: {
          id: string;
          user_id: string;
          started_at: string;
          last_ping_at: string;
          duration_s: number;
          path: string | null;
          user_agent: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          started_at?: string;
          last_ping_at?: string;
          duration_s?: number;
          path?: string | null;
          user_agent?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          started_at?: string;
          last_ping_at?: string;
          duration_s?: number;
          path?: string | null;
          user_agent?: string | null;
        };
        Relationships: [];
      };
      user_training_summary: {
        Row: {
          id: string | null;
          email: string | null;
          full_name: string | null;
          enrolled_at: string | null;
          last_sign_in_at: string | null;
          total_session_s: number | null;
          session_count: number | null;
          lessons_completed: number | null;
          lessons_viewed: number | null;
          lesson_time_s: number | null;
          quiz_attempts: number | null;
          quiz_passed: number | null;
          avg_score: number | null;
          first_session: string | null;
          last_session: string | null;
        };
        Insert: {
          id?: string | null;
          email?: string | null;
          full_name?: string | null;
          enrolled_at?: string | null;
          last_sign_in_at?: string | null;
          total_session_s?: number | null;
          session_count?: number | null;
          lessons_completed?: number | null;
          lessons_viewed?: number | null;
          lesson_time_s?: number | null;
          quiz_attempts?: number | null;
          quiz_passed?: number | null;
          avg_score?: number | null;
          first_session?: string | null;
          last_session?: string | null;
        };
        Update: {
          id?: string | null;
          email?: string | null;
          full_name?: string | null;
          enrolled_at?: string | null;
          last_sign_in_at?: string | null;
          total_session_s?: number | null;
          session_count?: number | null;
          lessons_completed?: number | null;
          lessons_viewed?: number | null;
          lesson_time_s?: number | null;
          quiz_attempts?: number | null;
          quiz_passed?: number | null;
          avg_score?: number | null;
          first_session?: string | null;
          last_session?: string | null;
        };
        Relationships: [];
      };
      xp_events: {
        Row: {
          id: string;
          user_id: string;
          kind: string;
          points: number;
          ref_id: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          kind: string;
          points: number;
          ref_id?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          kind?: string;
          points?: number;
          ref_id?: string | null;
          created_at?: string;
        };
        Relationships: [];
      };
    };
    Views: {
      accessibility_overview: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          a11y_rqth: boolean | null;
          a11y_font_scale: number | null;
          a11y_dyslexia_font: boolean | null;
          a11y_high_contrast: boolean | null;
          a11y_reduced_motion: boolean | null;
          a11y_underline_links: boolean | null;
          a11y_notes: string | null;
          open_requests: number | null;
          last_request_at: string | null;
        };
      };
      acquisition_attribution: {
        Row: {
          visitor_id: string | null;
          user_id: string | null;
          utm_source: string | null;
          utm_medium: string | null;
          utm_campaign: string | null;
          utm_content: string | null;
          utm_term: string | null;
          referrer: string | null;
          landing_page: string | null;
          first_touch_at: string | null;
        };
      };
      crm_pipeline_counters: {
        Row: {
          status: string | null;
          count: number | null;
          unassigned_count: number | null;
          overdue_count: number | null;
        };
      };
      formations_demand: {
        Row: {
          formation_slug: string | null;
          requests: number | null;
          requests_30d: number | null;
          pending: number | null;
          converted: number | null;
          refused: number | null;
          last_request_at: string | null;
        };
      };
      funder_overview: {
        Row: {
          funder_id: string | null;
          funder_name: string | null;
          portal_user_id: string | null;
          enrollments_total: number | null;
          enrollments_active: number | null;
          enrollments_done: number | null;
          budget_total_cents: number | null;
          budget_paid_cents: number | null;
        };
      };
      funder_recent_events: {
        Row: {
          event_kind: string | null;
          ref_id: string | null;
          funder_id: string | null;
          user_id: string | null;
          occurred_at: string | null;
          student_name: string | null;
          formation_title: string | null;
          status: string | null;
        };
      };
      funder_student_details: {
        Row: {
          enrollment_id: string | null;
          funder_id: string | null;
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          phone: string | null;
          formation_title: string | null;
          formation_slug: string | null;
          formation_code: string | null;
          pack: string | null;
          status: string | null;
          funding_kind: string | null;
          total_amount_cents: number | null;
          paid_amount_cents: number | null;
          enrollment_created_at: string | null;
          start_date: string | null;
          end_date: string | null;
          session_label: string | null;
          cpf_dossier_ref: string | null;
          lessons_done: number | null;
          lessons_total: number | null;
          avg_score: number | null;
          mock_exam_attempted: boolean | null;
          certified: boolean | null;
          last_active_at: string | null;
          days_since_last_activity: number | null;
        };
      };
      leaderboard_public: {
        Row: {
          rank: number | null;
          user_id: string | null;
          display_name: string | null;
          total_xp: number | null;
          level: number | null;
        };
      };
      pending_qr_corrections: {
        Row: {
          attempt_id: string | null;
          student_id: string | null;
          student_name: string | null;
          student_email: string | null;
          quiz_id: string | null;
          quiz_title: string | null;
          is_mock_exam: boolean | null;
          finished_at: string | null;
          status: string | null;
          formation_id: string | null;
          formation_slug: string | null;
          formation_code: string | null;
          qr_total: number | null;
          qr_pending: number | null;
        };
      };
      quiz_question_flag_rate: {
        Row: {
          quiz_id: string | null;
          quiz_title: string | null;
          question_id: string | null;
          times_flagged: number | null;
        };
      };
      search_top_queries: {
        Row: {
          query: string | null;
          searches: number | null;
          empty_results: number | null;
          empty_rate_pct: number | null;
          last_searched_at: string | null;
        };
      };
      survey_stats: {
        Row: {
          type: string | null;
          total: number | null;
          avg_globale: number | null;
          avg_contenu: number | null;
          avg_pedagogie: number | null;
          avg_plateforme: number | null;
          avg_accompagnement: number | null;
          avg_nps: number | null;
        };
      };
      trainer_formation_overview: {
        Row: {
          trainer_id: string | null;
          formation_id: string | null;
          slug: string | null;
          code: string | null;
          title: string | null;
          category: string | null;
          is_lead: boolean | null;
          can_grade: boolean | null;
          can_edit_content: boolean | null;
          active_students: number | null;
        };
      };
      trainer_my_students: {
        Row: {
          trainer_id: string | null;
          student_id: string | null;
          assignment_role: string | null;
          formation_slug: string | null;
          full_name: string | null;
          email: string | null;
          disabled: boolean | null;
          last_activity_at: string | null;
          lessons_done: number | null;
          quizzes_passed: number | null;
        };
      };
      trainer_revenue_summary: {
        Row: {
          trainer_user_id: string | null;
          trainer_name: string | null;
          events_count: number | null;
          gross_total_cents: number | null;
          platform_fee_total_cents: number | null;
          trainer_share_total_cents: number | null;
          paid_to_trainer_cents: number | null;
          pending_to_trainer_cents: number | null;
        };
      };
      user_credit_balance: {
        Row: {
          user_id: string | null;
          balance_cents: number | null;
        };
      };
      user_daily_activity: {
        Row: {
          user_id: string | null;
          day: string | null;
          sessions: number | null;
          total_seconds: number | null;
          first_connection: string | null;
          last_activity: string | null;
        };
      };
      vw_admin_acquisition_daily: {
        Row: {
          day: string | null;
          source: string | null;
          visitors: number | null;
        };
      };
      vw_admin_activity_heatmap: {
        Row: {
          day_of_week: number | null;
          hour_of_day: number | null;
          attempts: number | null;
        };
      };
      vw_admin_at_risk_students: {
        Row: {
          user_id: string | null;
          email: string | null;
          full_name: string | null;
          formation_slug: string | null;
          formation_title: string | null;
          formation_code: string | null;
          accent_color: string | null;
          pack: string | null;
          enrolled_at: string | null;
          last_active_at: string | null;
          days_inactive: number | null;
        };
      };
      vw_admin_completion_by_formation: {
        Row: {
          formation_id: string | null;
          formation_slug: string | null;
          formation_title: string | null;
          formation_code: string | null;
          accent_color: string | null;
          enrolled_count: number | null;
          completion_pct: number | null;
          total_lessons_done: number | null;
          total_lessons_available: number | null;
        };
      };
      vw_admin_funnel_by_utm: {
        Row: {
          source: string | null;
          medium: string | null;
          campaign: string | null;
          visitors: number | null;
          signups: number | null;
          enrollments: number | null;
          conversion_pct: number | null;
          first_seen_at: string | null;
          last_seen_at: string | null;
        };
      };
      vw_admin_funnel_conversion: {
        Row: {
          signups: number | null;
          lesson_viewers: number | null;
          quiz_attempters: number | null;
          quiz_passers: number | null;
          payers: number | null;
        };
      };
      vw_admin_kpis_realtime: {
        Row: {
          active_students_7d: number | null;
          at_risk_students: number | null;
          quiz_attempts_7d: number | null;
          live_sessions_scheduled: number | null;
          live_sessions_completed_30d: number | null;
          active_enrollments: number | null;
          revenue_30d_cents: number | null;
          new_users_7d: number | null;
          pass_rate_30d: number | null;
          mock_exams_30d: number | null;
          pending_corrections: number | null;
          computed_at: string | null;
        };
      };
      vw_admin_qualiopi_indicators: {
        Row: {
          hours_trained_total: number | null;
          hours_trained_30d: number | null;
          abandon_rate_pct: number | null;
          avg_completion_days: number | null;
          rncp_success_count: number | null;
          rncp_attempted_count: number | null;
          rncp_success_rate_pct: number | null;
        };
      };
      vw_admin_quiz_outliers: {
        Row: {
          quiz_id: string | null;
          quiz_title: string | null;
          is_mock_exam: boolean | null;
          pass_threshold: number | null;
          attempts_count: number | null;
          passed_count: number | null;
          avg_score: number | null;
          pass_rate_pct: number | null;
          difficulty_flag: string | null;
        };
      };
      vw_admin_revenue_by_formation_pack: {
        Row: {
          formation_id: string | null;
          formation_slug: string | null;
          formation_title: string | null;
          formation_code: string | null;
          accent_color: string | null;
          pack: string | null;
          enrollments_count: number | null;
          revenue_cents: number | null;
          commitment_cents: number | null;
        };
      };
      vw_admin_top_campaigns: {
        Row: {
          campaign: string | null;
          source: string | null;
          visitors: number | null;
          signups: number | null;
          started_at: string | null;
          last_seen_at: string | null;
        };
      };
      vw_admin_top_students: {
        Row: {
          user_id: string | null;
          full_name: string | null;
          email: string | null;
          lessons_completed_30d: number | null;
          quiz_attempts_30d: number | null;
          quiz_passed_30d: number | null;
          last_quiz_at: string | null;
          activity_score: number | null;
        };
      };
      vw_admin_trends_30d: {
        Row: {
          day: string | null;
          signups: number | null;
          quiz_attempts: number | null;
          payments: number | null;
        };
      };
      vw_admin_trends_by_formation: {
        Row: {
          formation_id: string | null;
          formation_slug: string | null;
          formation_title: string | null;
          formation_code: string | null;
          accent_color: string | null;
          day: string | null;
          quiz_attempts: number | null;
        };
      };
      vw_admin_upcoming_sessions_14d: {
        Row: {
          id: string | null;
          title: string | null;
          kind: string | null;
          start_at: string | null;
          end_at: string | null;
          status: string | null;
          max_participants: number | null;
          meeting_provider: string | null;
          formation_slug: string | null;
          formation_title: string | null;
          formation_code: string | null;
          accent_color: string | null;
          enrolled_count: number | null;
        };
      };
    };
    Functions: { [key: string]: unknown };
    Enums: { [key: string]: unknown };
  };
}

// Helpers : Tables<"profiles">, etc.
type PublicSchema = Database["public"];
export type Tables<T extends keyof PublicSchema["Tables"]> =
  PublicSchema["Tables"][T]["Row"];
export type TablesInsert<T extends keyof PublicSchema["Tables"]> =
  PublicSchema["Tables"][T]["Insert"];
export type TablesUpdate<T extends keyof PublicSchema["Tables"]> =
  PublicSchema["Tables"][T]["Update"];
