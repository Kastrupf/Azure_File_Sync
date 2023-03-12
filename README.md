<h1 align="center">
Azure File Sync
</h1>

<h3 align="center">
Atelier réalisé par TFTEC Cloud Company Brésil
</h3>
<h5 align="center">
Le 08 mars 2023, en distantiel.
</h5>

<p align="center">
<img width="1400" alt="Azure-File-Sync" src="https://user-images.githubusercontent.com/43493818/224551830-a9b6ad1d-f746-412c-87d7-ea20ce1dc224.png">
</p>

## **Le service Azure File Sync**

Azure File Sync est un outil pratique pour les entreprises qui souhaitent transférer une grande quantité de données vers le cloud tout en offrant une expérience utilisateur fluide. L'utilisation de cette solution offre plusieurs avantages:

- Réduction des coûts de stockage: Azure File Sync permet de déplacer les données moins fréquemment utilisées vers le cloud, ce qui réduit les coûts de stockage local. Vous pouvez également réduire les coûts d'infrastructure en utilisant le stockage dans le cloud plutôt que de dépenser de l'argent pour l'achat et la maintenance de disques durs.

- Amélioration des performances: Les utilisateurs peuvent accéder aux fichiers rapidement, même s'ils sont stockés dans le cloud. Avec Azure File Sync, vous pouvez synchroniser les fichiers les plus fréquemment utilisés sur un serveur local pour améliorer les performances et réduire les temps d'accès.

- Protection des données: Les données sont stockées dans le cloud, offrant ainsi une protection contre les pannes matérielles et les sinistres tels que les incendies ou les inondations.

- Flexibilité: Avec Azure File Sync, vous pouvez synchroniser des données entre plusieurs serveurs et plusieurs emplacements, ce qui permet une grande flexibilité dans la gestion des données.

- Facilité de gestion: Azure File Sync est facile à configurer et à gérer, ce qui permet aux administrateurs système de se concentrer sur des tâches plus importantes.

En résumé, Azure File Sync est une solution de stockage de données efficace et rentable qui offre des performances améliorées, une protection des données et une grande flexibilité pour les entreprises qui cherchent à transférer une grande quantité de données vers le cloud.


## **Provisionnement de l'infrastructure avec Terraform**

Pour réaliser le laboratoire, deux régions ont été utilisées : la région "Central France" pour symboliser le réseau on-premises et la région "UK South" pour Azure.

Dans un premier temps, Terraform a créé le groupe de ressources, les deux réseaux (VNET), l'un local et l'autre sur Azure ; un sous-réseau local et deux sous-réseaux côté Azure : un sous-réseau standard et un autre pour le réseau virtuel de passerelle.

Ensuite, quatre machines virtuelles de type Windows Server 2022 ont été créées, chacune dans leur propre réseau respectif et leur sous-réseau créé précédemment.

Terraform a également créé les adresses IP publiques pour permettre l'accès à ces machines, deux groupes de sécurité de réseau - déjà configurés pour autoriser l'accès sur le port 3389 pour l'adresse du sous-réseau standard - et a associé ces groupes de sécurité à ces deux sous-réseaux.

Après avoir créé la structure des machines, les adresses IP publiques et les accès pour les machines, Terraform a déployé la passerelle de réseau virtuel avec toutes les configurations nécessaires du réseau local, avec la sortie de l'adresse IP de VM-FW et la clé pour la connexion VPN, laissant tout le côté Azure déjà prêt.

Une fois la première étape du déploiement avec Terraform terminée, la VM-FW a été configurée pour le pare-feu dans le RAS, fermant la connexion VPN avec le côté Azure.

Sur la machine contenant le serveur de fichiers, Terraform a ajouté un disque secondaire, une unité de données. Il ne restait plus qu'à formater ce disque dans Windows.

La VM-AD a eu la forêt Active Directory installée via un script PowerShell, avec l'adresse du serveur DNS nécessaire pour suivre le chemin vert justement utilisé pour la réplication du serveur de fichiers vers File Sync sur Azure.


## **Visualiseur des ressources sur Azure**

Après le deployement du service File Sync, un diagramme visuel de l'environnement Azure a été generé, permetant de voir les dépendances entre les ressources et de comprendre comment elles interagissent.

<img width="1400" alt="ResourceVisualizerXL" src="https://user-images.githubusercontent.com/43493818/224553548-ea4347ce-26c2-4296-b13f-57b4fbee19cb.png">

---

Organisé par [TFTEC Cloud Company](https://www.tftec.com.br). 
Fait avec ❤️ par Fernanda ORLANDO 
Suivez-moi sur [LinkedIn](https://www.linkedin.com/in/fernandaorlando).

---
