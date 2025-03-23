#!/usr/bin/env lua

-- Configuration
local testDir = "tests"
local separator = string.rep("-", 50)

-- Function to get all test files in the specified directory
local function getTestFiles(dir)
    local testFiles = {}
    local handle = io.popen("dir " .. dir .. " /b")
    if not handle then
        print("Error: Failed to access directory " .. dir)
        os.exit(1)
    end

    local result = handle:read("*a")
    handle:close()
    
    for file in string.gmatch(result, "[^\r\n]+") do
        if file:match("^test_.+%.lua$") then
            table.insert(testFiles, file)
        end
    end
    
    return testFiles
end

-- Function to run a test file and capture output
local function runTest(dir, file)
    print(separator)
    print("Running test: " .. file)
    print(separator)
    
    local command = "cd " .. dir .. " && lua " .. file
    local handle = io.popen(command)
    if not handle then
        print("Error: Failed to run test " .. file)
        return false
    end
    
    local result = handle:read("*a")
    local success = handle:close()
    
    print(result)
    return success
end

-- Main function
local function main()
    print("Alchemy Factory Test Runner")
    print(separator)
    
    local testFiles = getTestFiles(testDir)
    
    if #testFiles == 0 then
        print("No test files found in directory: " .. testDir)
        os.exit(1)
    end
    
    print("Found " .. #testFiles .. " test files")
    
    local passed = 0
    local failed = 0
    local failedTests = {}
    
    for _, file in ipairs(testFiles) do
        if runTest(testDir, file) then
            passed = passed + 1
        else
            failed = failed + 1
            table.insert(failedTests, file)
        end
    end
    
    print(separator)
    print("Test Results:")
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    
    if failed > 0 then
        print("\nFailed tests:")
        for _, file in ipairs(failedTests) do
            print("  - " .. file)
        end
        os.exit(1)
    end
    
    print("\nAll tests passed!")
    os.exit(0)
end

-- Run the main function
main() 