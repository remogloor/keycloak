var attributes = {};

function processRole(roleModel, attr) {
    var map = roleModel.getAttributes();
    map.forEach(function(key, value){
        attr[key] = value;
    });
    
    if (roleModel.isComposite()) {
        roleModel.getComposites().forEach(function(roleModel) {
            attr = processRole(roleModel, attr);
        });
    }
    
    return attr;
}

user.getGroups().forEach(function(groupModel) {
    var map = groupModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    });
    
    groupModel.getRoleMappings().forEach(function(roleModel) {
        attributes = processRole(roleModel, attributes);
    });
});

user.getRoleMappings().forEach(function(roleModel) {
    attributes = processRole(roleModel, attributes);
});

exports = attributes;
