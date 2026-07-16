# Déploiement de modification sur la branche "main"
git checkout main
git merge develop --no-edit --message "Merge develop into main"
git push origin main