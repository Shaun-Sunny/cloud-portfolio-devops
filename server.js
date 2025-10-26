const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.use(express.json());
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

app.get('/api/projects', (req, res) => {
  res.json([
    { "name": "DevOps Pipeline", "tech": "Azure + Docker + Terraform + Ansible" },
    { "name": "Cloud Portfolio", "tech": "Node.js + Express + Kubernetes" }
  ]);
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
