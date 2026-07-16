# Déploiement de modification sur la branche "develop"
git checkout develop
git merge feature/TravelApproval --no-edit --message "Merge feature/TravelApproval into develop"
git push origin develop