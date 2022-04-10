var attributes = {};

user.getGroups().forEach(function(groupModel) {
    var map = groupModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    });
    
    groupModel.getRoleMappings().forEach(function(roleModel) {
        var map = roleModel.getAttributes();
        map.forEach(function(key, value){
            attributes[key] = value;
        }); 
    });
});

user.getRoleMappings().forEach(function(roleModel) {
    var map = roleModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    }); 
});

exports = attributes;
