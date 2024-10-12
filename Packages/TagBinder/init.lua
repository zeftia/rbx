local CollectionService = game:GetService("CollectionService")
local TagBinder = {}
TagBinder.__index = TagBinder

function TagBinder.new(tag, class)
    local self = setmetatable({}, TagBinder)

    local function add(instance)
        if self._Objects[instance] then
            return
        end
        local new = class.new(instance)
        self._Objects[instance] = new
        if new.Start then
            new:Start()
        end
    end

    local function rem(instance)
        local object = self._Objects[instance]
        if not object then
            return
        end
        self._Objects[instance] = nil
        if object.Destroy then
            object:Destroy()
        end
    end

    self._Objects = {}
    self._Connections = {
        CollectionService:GetInstanceAddedSignal(tag):Connect(add),
        CollectionService:GetInstanceRemovedSignal(tag):Connect(rem)
    }

    for _, instance in CollectionService:GetTagged(tag) do
        task.spawn(add, instance)
    end
    return self
end

return TagBinder