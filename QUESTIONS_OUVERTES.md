# Questions ouvertes

Ces questions ne bloquent pas la documentation actuelle. Elles bloquent en revanche une migration propre vers un fonctionnement proche d'`infra-deploy`.

## Perimetre

1. Le depot doit-il gerer uniquement tes postes de travail, ou aussi des serveurs personnels de maniere durable ?
2. Veux-tu un profil `server_home` dans ce depot, ou preferes-tu garder tout serveur dans un depot separe ?
3. Le groupe `epiconcept` dans `hosts` doit-il rester ici, ou est-il historique depuis la creation d'`infra-deploy` ?

## Profils de machines

4. Quels profils veux-tu reconnaitre officiellement : `workstation`, `laptop`, `desktop`, `home`, `server`, `dev`, `minimal` ?
5. Quelles machines actuelles doivent servir de reference pour chaque profil ?
6. Les chemins `/home/nas`, `/home/freebox`, `/home/epiconcept` sont-ils toujours a creer sur tous les postes, ou seulement sur les machines maison ?

## Utilisateur et secrets

7. Le projet doit-il rester specialise sur l'utilisateur `cedric`, ou veux-tu le rendre parametrable proprement ?
8. Comment veux-tu gerer les secrets et tokens personnels : fichiers Syncthing existants, Ansible Vault, KeePass, variables locales non versionnees ?
9. La cle API Syncthing doit-elle rester lue depuis `~/.config/bin_ss`, ou devenir une variable d'inventaire ?

## Syncthing et donnees synchronisees

10. Syncthing est-il un prerequis manuel du poste neuf, ou le role doit-il suffire a amorcer la synchronisation ?
11. La liste des devices Syncthing doit-elle etre versionnee dans ce depot ?
12. Les partages Syncthing commentes dans `syncthing-install` doivent-ils etre reactives, variables, ou abandonnes ?

## Actions manuelles

13. `~/manuel.sh` doit-il devenir une interface officielle du projet ?
14. Si oui, veux-tu un role dedie qui initialise, dedoublonne et affiche ce fichier en fin de run ?
15. Les clones Git/SVN doivent-ils rester manuels par defaut, ou veux-tu tenter une automatisation directe avec gestion explicite des echecs d'authentification ?

## Controle de `/etc`

16. Veux-tu migrer de Mercurial direct vers `etckeeper` ?
17. Si oui, Git ou Mercurial comme backend etckeeper ?
18. Souhaites-tu encadrer chaque role par un commit avant/apres comme `infra-deploy`, ou seulement le debut et la fin d'un run complet ?

## Modernisation

19. Quelle distribution cible minimale faut-il supporter aujourd'hui : Ubuntu 20.04, 22.04, 24.04, Debian 12, Debian 13 ?
20. Docker doit-il rester sur `docker.io` Ubuntu, ou passer sur Docker CE + plugin Compose ?
21. Les roles obsoletes (`keepassx`, `kpcli`, `rambox`, `teamviewer`, `terraform 0.6`, `ocsinventory`) doivent-ils etre archives, gardes en `legacy.list`, ou supprimes plus tard ?

## Alignement avec infra-deploy

22. `run_role.yml` et `run` existent maintenant. Souhaites-tu garder durablement `play.sh` comme compatibilite, ou le deprecier rapidement ?
23. Veux-tu des fichiers `*.list` executes comme dans `infra-deploy`, ou des playbooks par profil ?
24. Souhaites-tu une infra de test Docker pour ce depot, ou le cout n'est pas justifie pour des postes personnels ?

## Ma recommandation par defaut

Sans reponse contraire, je partirais sur ces hypotheses :

- depot personnel multi-profils, pas seulement workstation;
- utilisateur parametrable mais valeur par defaut `cedric`;
- `~/manuel.sh` conserve et officialise;
- `etckeeper` remplace Mercurial direct;
- `run` + `run_role.yml` + `*.list` ajoutes avant toute refonte de role;
- roles historiques gardes dans `legacy.list` tant qu'ils n'ont pas ete explicitement abandonnes.
