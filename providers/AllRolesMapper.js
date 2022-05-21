var roles = [];

user.getRoleMappings().forEach(function(roleModel) {
    roles.push(roleModel.getName());
});

exports = roles;
