-- MIT License
-- Blake@github.com/DGHeroin/async.lua

local async = {}
local unpack = unpack or table.unpack
local DEFAULT_MAX_PARALLEL_NUM = 5

-- @luadoc 瀑布流执行
-- @params tasks    array    函数数组
-- @params resultCb functino 最终回调
function async.waterfall(tasks, resultCb)
    local nextArg = {}
    local next
    local error
    resultCb = resultCb or function () end

    next = function()
        if #tasks == 0 then
            if resultCb then
                resultCb(error, unpack(nextArg))
            end
            resultCb = nil
            return
        end
        if error then
            tasks = {} -- 清空序列
            resultCb(error, unpack(nextArg))
            return
        end
        local err = nil
        local v = table.remove(tasks, 1)
        v(function(err, ...)
            local arg = {...}
            nextArg = arg
            if err then
                error = err
            end
            next()
        end, unpack(nextArg))
    end
    next()
end

-- @luadoc 并行执行
-- @params num      number|nil 并行调用数量 默认5
-- @params tasks    array      函数数组
-- @params resultCb functino   最终回调
function async.parallel(MAX_PARALLEL_NUM, tasks, resultCb)
    if type(MAX_PARALLEL_NUM) ~= 'number' then
        async.parallel(DEFAULT_MAX_PARALLEL_NUM, MAX_PARALLEL_NUM, tasks)
        return
    end
    local count = 0
    local result = {}
    resultCb = resultCb or function () end
    local function invokeFinal(err)
        if not resultCb then return end
        resultCb(err, result)
        resultCb = nil
    end
    local function invoke(i, task)
        task(function (err, ...)
            count = count + 1
            local args  = {...}
            result[i] = args
            if err then -- 终止
                invokeFinal(err)
                return
            end
            if count == #tasks then
                invokeFinal()
            end
        end)
    end
    if #tasks <= MAX_PARALLEL_NUM then
        for index, value in ipairs(tasks) do
            invoke(index, value)
        end
    else -- 并行处理太多了
        -- 拆分任务组
        local groupTasks = {}
        local groupIdx = 1
        for _, value in ipairs(tasks) do
            local m = groupTasks[groupIdx] or {}
            groupTasks[groupIdx] = m
            table.insert(m, value)
            if #m >= MAX_PARALLEL_NUM then
                groupIdx = groupIdx + 1
            end
        end
        -- 按组顺序执行
        local fns = {}
        local function makeFunc(smallTasks)
            return function (next)
                async.parallel(smallTasks, next)
            end
        end
        for _, value in ipairs(groupTasks) do
            table.insert(fns, makeFunc(value))
        end
        async.waterfall(fns, invokeFinal)
    end
end


return async