class MakeSisIdsUnique < ActiveRecord::Migration
  tag :postdeploy
  self.transactional = false

  def self.up
    add_index :accounts, [:sis_source_id, :root_account_id], conditions: "sis_source_id IS NOT NULL", unique: true, concurrently: true
    add_index :accounts, :root_account_id, concurrently: true
    add_index :courses, [:sis_source_id, :root_account_id], conditions: "sis_source_id IS NOT NULL", unique: true, concurrently: true
    add_index :course_sections, [:sis_source_id, :root_account_id], conditions: "sis_source_id IS NOT NULL", unique: true, concurrently: true
    add_index :enrollment_terms, [:sis_source_id, :root_account_id], conditions: "sis_source_id IS NOT NULL", unique: true, concurrently: true
    add_index :enrollment_terms, :root_account_id, concurrently: true
    if connection.adapter_name == 'PostgreSQL'
      concurrently = " CONCURRENTLY" if connection.open_transactions == 0
      execute "CREATE UNIQUE INDEX#{concurrently} index_pseudonyms_on_unique_id_and_account_id ON pseudonyms (LOWER(unique_id), account_id) WHERE workflow_state='active'"
      remove_index :pseudonyms, :unique_id
    end
    add_index :pseudonyms, [:sis_user_id, :account_id], conditions: "sis_user_id IS NOT NULL", unique: true, concurrently: true
    add_index :pseudonyms, :account_id, concurrently: true
    add_index :groups, [:sis_source_id, :root_account_id], conditions: "sis_source_id IS NOT NULL", unique: true, concurrently: true

    remove_index :accounts, :sis_source_id
    remove_index :accounts, [:root_account_id, :sis_source_id]
    remove_index :courses, :sis_source_id
    remove_index :course_sections, [:root_account_id, :sis_source_id]
    remove_index :enrollment_terms, :sis_source_id
    remove_index :enrollment_terms, [:root_account_id, :sis_source_id]
    remove_index :pseudonyms, :sis_user_id
  end

  def self.down
    add_index :accounts, :sis_source_id, concurrently: true
    add_index :accounts, [:root_account_id, :sis_source_id], concurrently: true
    add_index :courses, :sis_source_id, concurrently: true
    add_index :course_sections, [:root_account_id, :sis_source_id], concurrently: true
    add_index :enrollment_terms, :sis_source_id, concurrently: true
    add_index :enrollment_terms, [:root_account_id, :sis_source_id], concurrently: true
    add_index :pseudonyms, :sis_user_id, concurrently: true

    remove_index :accounts, [:sis_source_id, :root_account_id]
    remove_index :accounts, :root_account_id
    remove_index :courses, [:sis_source_id, :root_account_id]
    remove_index :course_sections, [:sis_source_id, :root_account_id]
    remove_index :enrollment_terms, [:sis_source_id, :root_account_id]
    remove_index :enrollment_terms, :root_account_id
    if connection.adapter_name == 'PostgreSQL'
      remove_index :pseudonyms, [:unique_id, :account_id]
    end
    remove_index :pseudonyms, [:sis_user_id, :account_id]
    remove_index :pseudonyms, :account_id
    remove_index :groups, [:sis_source_id, :root_account_id]
  end
end
