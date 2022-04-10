var roles = {}
for each (var role in user.getRoleMappings()) {
    roles[role.name] = role.getAttributes();
}
token.setOtherClaims('roles', roles);
