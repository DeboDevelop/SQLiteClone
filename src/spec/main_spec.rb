describe 'database' do
    def run_script(commands)
        raw_output = nil
        IO.popen("./db.out", "r+") do |pipe|
            commands.each do |command|
                pipe.puts command
            end

            pipe.close_write

            # Read entire output
            raw_output = pipe.gets(nil)
        end
        raw_output.split("\n")
    end

    it 'inserts and retrieves a row' do
        result = run_script([
            "insert 1 user1 person1@example.com",
            "select",
            ".exit",
        ])
        expect(result).to match_array([
            "Executed.",
            "SQLite > (1, user1, person1@example.com)",
            "SQLite > Executed.",
            "SQLite > Exiting Gracefully."
        ]) 
    end

    it 'prints error message when table is full' do
        script = (1..1501).map do |i|
            "insert #{i} user#{i} person#{i}@example.com"
        end
        script << ".exit"
        result = run_script(script)
        
        expect(result[-2]).to eq("SQLite > Error: Table full.")
    end
    it 'allows inserting strings that are the maximum length' do
        long_username = "a"*32
        long_email = "a"*255
        script = [
            "insert 1 #{long_username} #{long_email}",
            "select",
            ".exit",
        ]
        result = run_script(script)
        expect(result).to match_array([
            "SQLite > Executed.",
            "SQLite > (1, #{long_username}, #{long_email})",
            "Executed.",
            "SQLite > Exiting Gracefully."
        ])
    end
end