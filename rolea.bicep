resource rgowner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('abs')
  properties: {
    principalId: '645ad4db-be41-4471-9f34-ae48367f80a6'
    roleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  }
}
resource rgowner1 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('at6bs')
  properties: {
    principalId: '7e99074c-62cf-474e-948d-9c264a5eb354'
    roleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  }
}
