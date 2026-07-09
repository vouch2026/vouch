 CREATE OR REPLACE FUNCTION public.reset_academic_year_data()                                                                                                
    RETURNS VOID AS $$                                                                                                                                          
    DECLARE                                                                                                                                                     
        v_member_role_id UUID;                                                                                                                                  
        v_voter_role_id UUID;                                                                                                                                   
    BEGIN                                                                                                                                                       
        -- 1. Retrieve IDs of default student roles                                                                                                             
        SELECT id INTO v_member_role_id FROM public.roles WHERE name = 'Member';                                                                                
        SELECT id INTO v_voter_role_id FROM public.roles WHERE name = 'Voters';                                                                                 
                                                                                                                                                                
        -- 2. Delete adviser memberships (so they do not become standard student members)                                                                       
        DELETE FROM public.organization_members                                                                                                                 
        WHERE role_id = (SELECT id FROM public.roles WHERE name = 'Adviser' LIMIT 1);                                                                           
                                                                                                                                                                
        -- 3. Reset student organization members to standard 'Member' role                                                                                      
        UPDATE public.organization_members                                                                                                                      
        SET role_id = v_member_role_id                                                                                                                          
        WHERE role_id IS DISTINCT FROM v_member_role_id;                                                                                                        
                                                                                                                                                                
        -- 4. Reset comselec members to standard 'Voters' role                                                                                                  
        UPDATE public.comselec_members                                                                                                                          
        SET role_id = v_voter_role_id                                                                                                                           
        WHERE role_id IS DISTINCT FROM v_voter_role_id;                                                                                                         
                                                                                                                                                                
        -- 5. Delete transient officer roles from user_roles                                                                                                    
        DELETE FROM public.user_roles                                                                                                                           
        WHERE role_id NOT IN (                                                                                                                                  
            SELECT id FROM public.roles                                                                                                                         
            WHERE name IN ('Super Admin', 'Faculty Dean', 'Program Head', 'Instructor', 'Personnel', 'Students', 'Voters')                                      
        );                                                                                                                                                      
                                                                                                                                                                
        -- 6. Clear adviser assignments on organizations                                                                                                        
        UPDATE public.organizations                                                                                                                             
        SET adviser_name = NULL                                                                                                                                 
        WHERE id IS NOT NULL;                                                                                                                                   
                                                                                                                                                                
        -- 7. Reset clearance periods in organization & comselec settings                                                                                       
        UPDATE public.organization_settings                                                                                                                     
        SET clearance_period_start = NULL,                                                                                                                      
            clearance_period_end = NULL                                                                                                                         
        WHERE organization_id IS NOT NULL;                                                                                                                      
                                                                                                                                                                
        UPDATE public.comselec_settings                                                                                                                         
        SET clearance_period_start = NULL,                                                                                                                      
            clearance_period_end = NULL                                                                                                                         
        WHERE comselec_id IS NOT NULL;                                                                                                                          
                                                                                                                                                                
        -- 8. Delete clearance requests and signatures (Cascade deletes signature records)                                                                      
        DELETE FROM public.activity_card_clearance_requests                                                                                                     
        WHERE id IS NOT NULL;                                                                                                                                   
                                                                                                                                                                
        -- 9. Delete events, attendance, excuses (Cascade deletes attendance/excuses)                                                                           
        DELETE FROM public.events                                                                                                                               
        WHERE id IS NOT NULL;                                                                                                                                   
                                                                                                                                                                
        -- 10. Delete fees & payments (Cascade deletes payments)                                                                                                
        DELETE FROM public.fees                                                                                                                                 
        WHERE id IS NOT NULL;                                                                                                                                   
                                                                                                                                                                
        -- 11. Delete student sanctions and rules                                                                                                               
        DELETE FROM public.student_sanction_records                                                                                                             
        WHERE id IS NOT NULL;                                                                                                                                   
        DELETE FROM public.sanction_rules                                                                                                                       
        WHERE id IS NOT NULL;                                                                                                                                   
                                                                                                                                                                
        -- 12. Delete announcements                                                                                                                             
        DELETE FROM public.announcements                                                                                                                        
        WHERE id IS NOT NULL;                                                                                                                                   
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;
  



   DELETE FROM public.organization_members
    WHERE role_id = (SELECT id FROM public.roles WHERE name = 'Member')
      AND user_id IN (
          SELECT id FROM public.users 
          WHERE campus_id IS NOT NULL 
            AND id NOT IN (
                SELECT user_id FROM public.user_roles WHERE is_active = true
            )
            -- Or filter by emails/names of the advisers if you want to be selective:
            -- AND email IN ('adviser1@email.com', 'adviser2@email.com')
      );