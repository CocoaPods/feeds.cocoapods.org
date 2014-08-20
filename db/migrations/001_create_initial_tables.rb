Sequel.migration do
  up do
    create_table :pods do
      String :name, primary_key: true
      DateTime :created_at
      TrueClass :tweet_sent
      String :spec
    end
  end

  down do
    drop_table :pods
  end
end
