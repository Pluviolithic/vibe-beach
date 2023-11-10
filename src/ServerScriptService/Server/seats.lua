local seats = {}
for _, seat in ipairs(game:GetService("CollectionService"):GetTagged("Seat")) do
    local animation = seat:FindFirstChildWhichIsA("Animation")
    if not animation then continue end
    seats[seat] = animation.AnimationId
end
return seats
