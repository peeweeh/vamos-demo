# Test Phase: Deployment, Verification, and Documentation (Completed)

1.  **Deploy & Verify:**
    *   [x] Deploy the stack to `ap-southeast-1` using AWS credentials from environment variables.
    *   [x] **Seed Data:** Run the commands in `docs/runbook.md` to populate the services with sample data.
    *   [ ] Verify the ALB endpoint returns the nginx page with instance ID, S3 content, and DB status.
    *   [ ] **Test Interactive Form:**
        - Access the web form via ALB endpoint
        - Submit test data (e.g., visitor names)
        - Verify data is written to RDS database
        - Confirm entries are displayed on the page
        - Test multiple submissions to demonstrate live updates
    *   [ ] **DR Demo Scenario:**
        - Submit a name via the form (e.g., "Alice")
        - Take snapshot/backup
        - Submit another name (e.g., "Bob") 
        - Simulate disaster by destroying stack
        - Restore from snapshot
        - Verify only "Alice" appears (Bob's entry is lost, demonstrating rollback)
    *   [ ] Confirm all auxiliary services are created and contain the sample data.
2.  **Complete Documentation:**
    *   [x] Finalize `docs/architecture.md` with diagrams.
    *   [x] Complete `docs/runbook.md` with deployment and verification steps.
    *   [x] Update the main `README.md`.
