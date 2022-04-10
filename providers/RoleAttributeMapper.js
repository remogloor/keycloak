var attributes = {};

function processGroup(groupModel) {
    var map = groupModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    });
    
    groupModel.getSubGroups().forEach(function(subGroupModel) {
        processGroup(subGroupModel);
    }
    
    groupModel.getRoleMappings().forEach(function(roleModel) {
        var map = roleModel.getAttributes();
        map.forEach(function(key, value){
            attributes[key] = value;
        }); 
    });
}

user.getGroups().forEach(function(groupModel) {
    processGroup(groupModel);
});

user.getRoleMappings().forEach(function(roleModel) {
    var map = roleModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    }); 
});

exports = attributes;
