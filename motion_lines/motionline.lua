local List = require "motion_lines.list"

local M = {}

M.points = List.new()
M.points_upper = List.new()
M.points_lower = List.new()

M.stopped = false
M.min_range = 3 * 3
M.max_range = 20 * 20
M.remove_timer = 0.15

M.last_angle = 0
M.fully_disappeared = false

function M.reset()
    M.stopped = false
    M.fully_disappeared = false
end

function M.addPoint(point)
    -- local last_point: CGPoint? = M.points.last
    local last_point = {
        x = -1000,
        y = -1000
    }
    if (List.count(M.points) > 0) then
        last_point = List.last(M.points)
    end

    -- let dist_x: CGFloat = point.x - (last_point?.x ?? -1000)
    local dist_x = point.x - last_point.x

    -- let dist_y: CGFloat = point.y - (last_point?.y ?? -1000)
    local dist_y = point.y - last_point.y

    -- let square_dist: CGFloat = dist_x * dist_x + dist_y * dist_y
    local square_dist = dist_x * dist_x + dist_y * dist_y

    -- let min: CGFloat = M.min_range * M.min_range
    -- let max: CGFloat = M.max_range * M.max_range

    -- if ((last_point == nil) || (square_dist >= min && square_dist <= max))
    if (List.count(M.points) == 0) or (square_dist >= M.min_range and square_dist <= M.max_range) then
        List.append(M.points, point)
    end

    -- if (M.points.count > 1)
    if (List.count(M.points) >= 1) then
        -- let rad_angle = atan2(dist_y, dist_x)
        local rad_angle = math.atan2(dist_y, dist_x)

        -- if (M.last_angle == 0 || M.points.count == 2)
        if (M.last_angle == 0 or List.count(M.points) == 2) then
            M.last_angle = rad_angle
        end
        -- var diff_angle = rad_angle - M.last_angle
        local diff_angle = rad_angle - M.last_angle

        -- while(diff_angle < -CGFloat.pi)
        while (diff_angle < -math.pi) do
            diff_angle = diff_angle + math.pi * 2
        end

        -- while (diff_angle > math.pi)
        while (diff_angle > math.pi) do
            diff_angle = diff_angle - math.pi * 2
        end

        -- if (abs(diff_angle) > CGFloat.pi * 0.25)
        if (math.abs(diff_angle) > math.pi * 0.25) then
            M.stopped = true
        else
            local next_angle = rad_angle + math.pi * 0.5

            local upper_point = {
                x = 0,
                y = 0
            }

            upper_point.x = point.x + 4 * math.cos(next_angle)
            upper_point.y = point.y + 4 * math.sin(next_angle)

            List.append(M.points_upper, upper_point)

            next_angle = rad_angle - math.pi * 0.5

            local lower_point = {
                x = 0,
                y = 0
            }

            lower_point.x = point.x + 4 * math.cos(next_angle)
            lower_point.y = point.y + 4 * math.sin(next_angle)

            if (List.count(M.points_upper) > 4) then
                List.append(M.points_lower, lower_point)
            end
        end

        M.last_angle = rad_angle

        -- if (M.points.count > 30)
        if (List.count(M.points) > 30) then
            List.removeFirst(M.points)
        end

        -- if (M.points_upper.count > 25)
        if (List.count(M.points_upper) > 25) then
            List.removeFirst(M.points_upper)
        end

        if (List.count(M.points_lower) > 18) then
            List.removeFirst(M.points_lower)
        end

        M.stopped = false
    else
        M.stopped = true
    end
end

function M.createLines(points, min_range, max_range)
    local min = min_range * min_range
    local max = max_range * max_range

    drawpixels.removePath()

    if (List.count(points) >= 16) then
        drawpixels.moveTo(List.ValueAt(points, 7).x, List.ValueAt(points, 7).y)
        local last_point = List.ValueAt(points, 7)
        for i = 8, List.count(points) - 9, 1 do
            local point = List.ValueAt(points, i)
            local dist_x = point.x - last_point.x
            local dist_y = point.y - last_point.y
            local dist = dist_x * dist_x + dist_y * dist_y
            if (dist >= min and dist <= max) then
                drawpixels.lineTo(point.x, point.y)
            else
                drawpixels.moveTo(point.x, point.y)

                last_point = point
            end
        end
    end
    drawpixels.drawPath()

    drawpixels.removePath()
    if (List.count(points) >= 12) then
        drawpixels.moveTo(List.ValueAt(points, 5).x, List.ValueAt(points, 5).y)
        local last_point = List.ValueAt(points, 5)

        for i = 6, List.count(points) - 7, 1 do
            local point = List.ValueAt(points, i)
            local dist_x = point.x - last_point.x
            local dist_y = point.y - last_point.y
            local dist = dist_x * dist_x + dist_y * dist_y
            if (dist >= min and dist <= max) then
                drawpixels.lineTo(point.x, point.y)
            else
                drawpixels.moveTo(point.x, point.y)
            end
            last_point = point
        end
    end
    drawpixels.drawPath()

    drawpixels.removePath()

    if (List.count(points) >= 8) then
        drawpixels.moveTo(List.ValueAt(points, 3).x, List.ValueAt(points, 3).y)
        local last_point = List.ValueAt(points, 3)

        for i = 4, List.count(points) - 5, 1 do
            local point = List.ValueAt(points, i)
            local dist_x = point.x - last_point.x
            local dist_y = point.y - last_point.y
            local dist = dist_x * dist_x + dist_y * dist_y
            if (dist >= min and dist <= max) then
                drawpixels.lineTo(point.x, point.y)
            else
                drawpixels.moveTo(point.x, point.y)
            end

            last_point = point
        end
    end
    drawpixels.drawPath()

    drawpixels.removePath()
    if (List.count(points) >= 4) then
        -- print("the point is " .. List.ValueAt(points, 1).x)

        drawpixels.moveTo(List.ValueAt(points, 1).x, List.ValueAt(points, 1).y)

        local last_point = List.ValueAt(points, 1)

        for i = 2, List.count(points) - 3, 1 do
            local point = List.ValueAt(points, i)
            local dist_x = point.x - last_point.x
            local dist_y = point.y - last_point.y
            local dist = dist_x * dist_x + dist_y * dist_y
            if (dist >= min and dist <= max) then
                drawpixels.lineTo(point.x, point.y)
            else
                drawpixels.moveTo(point.x, point.y)
            end

            last_point = point
        end
    end

    drawpixels.drawPath()

    drawpixels.removePath()

    if (List.count(points) >= 2) then
        local last_point = List.first(points)
        drawpixels.moveTo(last_point.x, last_point.y)

        -- print("Last point" .. last_point.x)

        for i = 1, List.count(points) - 1, 1 do
            -- print("point i = ", i, List.ValueAt(points, i))
            local point = List.ValueAt(points, i)

            local dist_x = point.x - last_point.x
            local dist_y = point.y - last_point.y
            local dist = dist_x * dist_x + dist_y * dist_y
            if (dist >= min and dist <= max) then
                drawpixels.lineTo(point.x, point.y)
            else
                drawpixels.moveTo(point.x, point.y)
            end

            last_point = point
        end
    end
    drawpixels.drawPath()
end

function M.update(dt)
    M.createLines(M.points_lower, M.min_range, M.max_range)
    M.createLines(M.points_upper, M.min_range, M.max_range)

    if (M.stopped) then
        if (List.count(M.points) > 0) then
            List.removeFirst(M.points)
        end

        if (List.count(M.points_upper) > 0) then
            List.removeFirst(M.points_upper)
        end
        if (List.count(M.points_lower) > 0) then
            List.removeFirst(M.points_lower)
        end
        if (List.count(M.points) > 0) then
            List.removeFirst(M.points)
        end
        if (List.count(M.points_upper) > 0) then
            List.removeFirst(M.points_upper)
        end
        if (List.count(M.points_lower) > 0) then
            List.removeFirst(M.points_lower)
        end
        if (List.count(M.points) > 0) then
            List.removeFirst(M.points)
        end
        if (List.count(M.points_upper) > 0) then
            List.removeFirst(M.points_upper)
        end
        if (List.count(M.points_lower) > 0) then
            List.removeFirst(M.points_lower)
        end
        if (List.count(M.points) > 0) then
            List.removeFirst(M.points)
        end
        if (List.count(M.points_upper) > 0) then
            List.removeFirst(M.points_upper)
        end
        if (List.count(M.points_lower) > 0) then
            List.removeFirst(M.points_lower)
        end
        if (List.count(M.points) > 0) then
            List.removeFirst(M.points)
        end
        if (List.count(M.points_upper) > 0) then
            List.removeFirst(M.points_upper)
        end
        if (List.count(M.points_lower) > 0) then
            List.removeFirst(M.points_lower)
        end
        if (List.count(M.points) == 0 and List.count(M.points_lower) == 0 and List.count(M.points_upper) == 0) then
            M.stopped = false
            M.fully_disappeared = true
        end
    end
end

function M.stop()
    M.stopped = true
end

return M
