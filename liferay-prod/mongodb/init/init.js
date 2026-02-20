db = db.getSiblingDB('lportal');
db.createUser({
  user: 'liferay',
  pwd: 'liferayProd@123',
  roles: [{ role: 'readWrite', db: 'lportal' }]
});
