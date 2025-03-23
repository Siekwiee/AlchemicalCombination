-- Test Runner LÖVE Game
-- This is a minimal LÖVE game that just runs the test script

-- Configuration
local testDir = "../tests"
local separator = string.rep("-", 50)
local testResults = {
    passed = 0,
    failed = 0,
    failedTests = {},
    complete = false,
    output = {}
}

local font = love.graphics.newFont(12)
local headerFont = love.graphics.newFont(18)


-- Function to get all test files in the specified directory
local function getTestFiles(dir)
    local testFiles = {}
    -- Get absolute path by combining current directory with relative path
    local currentDir = love.filesystem.getSource()
    local absolutePath = currentDir .. "/" .. dir
    local handle = io.popen('dir "' .. absolutePath .. '" /b')
    if not handle then
        table.insert(testResults.output, "Error: Failed to access directory " .. dir)
        return {}
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
    table.insert(testResults.output, separator)
    table.insert(testResults.output, "Running test: " .. file)
    table.insert(testResults.output, separator)
    
    -- Get absolute path for running the test
    local currentDir = love.filesystem.getSource()
    local absolutePath = currentDir .. "/" .. dir
    local command = 'cd "' .. absolutePath .. '" && lua "' .. file .. '"'
    local handle = io.popen(command)
    if not handle then
        table.insert(testResults.output, "Error: Failed to run test " .. file)
        return false
    end
    
    local result = handle:read("*a")
    local success = handle:close()
    
    for line in result:gmatch("[^\r\n]+") do
        table.insert(testResults.output, line)
    end
    
    return success
end

function love.load()
    love.window.setTitle("Alchemy Factory Test Runner")
    love.window.setMode(800, 600, {
        resizable = true,
        vsync = true,
        minwidth = 400,
        minheight = 300
    })
    
    -- Set up fonts

    
    -- Start running tests
    table.insert(testResults.output, "\n\n" .. separator)
    table.insert(testResults.output, "  ALCHEMY FACTORY TEST RUNNER")
    table.insert(testResults.output, separator .. "\n")
    
    local testFiles = getTestFiles(testDir)
    
    if #testFiles == 0 then
        table.insert(testResults.output, "No test files found in directory: " .. testDir)
        testResults.complete = true
        return
    end
    
    table.insert(testResults.output, "Found " .. #testFiles .. " test files")
    
    for _, file in ipairs(testFiles) do
        if runTest(testDir, file) then
            testResults.passed = testResults.passed + 1
        else
            testResults.failed = testResults.failed + 1
            table.insert(testResults.failedTests, file)
        end
    end
    
    table.insert(testResults.output, separator)
    table.insert(testResults.output, "TEST RESULTS:")
    table.insert(testResults.output, separator)
    
    if testResults.passed > 0 then
        table.insert(testResults.output, "PASSED: " .. testResults.passed .. " test" .. (testResults.passed == 1 and "" or "s"))
    end
    
    if testResults.failed > 0 then
        table.insert(testResults.output, "FAILED: " .. testResults.failed .. " test" .. (testResults.failed == 1 and "" or "s"))
        table.insert(testResults.output, "\nFailed tests:")
        for i, file in ipairs(testResults.failedTests) do
            table.insert(testResults.output, "  " .. i .. ". " .. file)
        end
    else
        table.insert(testResults.output, "\nALL TESTS PASSED!")
    end
    
    testResults.complete = true
end

function love.draw()
    love.graphics.setFont(headerFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Alchemy Factory Test Runner", 20, 20)
    
    love.graphics.setFont(font)
    local y = 60
    
    -- Draw test results
    if testResults.complete then
        -- Draw summary
        if testResults.passed > 0 then
            love.graphics.setColor(0.2, 0.8, 0.2)
            love.graphics.print("PASSED: " .. testResults.passed, 20, y)
            y = y + 25
        end
        
        if testResults.failed > 0 then
            love.graphics.setColor(0.8, 0.2, 0.2)
            love.graphics.print("FAILED: " .. testResults.failed, 20, y)
            y = y + 25
        end
        
        -- Draw output
        love.graphics.setColor(1, 1, 1)
        y = y + 10
        for _, line in ipairs(testResults.output) do
            love.graphics.print(line, 20, y)
            y = y + 15
        end
    else
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.print("Running tests...", 20, y)
    end
    
    -- Draw instructions at bottom
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Press ESC to exit", 20, love.graphics.getHeight() - 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end 