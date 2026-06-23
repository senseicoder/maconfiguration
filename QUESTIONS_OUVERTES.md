# Questions ouvertes

Ces questions ne bloquent pas la documentation actuelle. Elles bloquent en revanche une migration propre vers un fonctionnement proche d'`infra-deploy`.

## Perimetre

1. Le depot doit-il gerer uniquement tes postes de travail, ou aussi des serveurs personnels de maniere durable ?
2. Veux-tu un profil `server_home` dans ce depot, ou preferes-tu garder tout serveur dans un depot separe ?
3. Le groupe `epiconcept` dans `hosts` doit-il rester ici, ou est-il historique depuis la creation d'`infra-deploy` ?

## Profils de machines

4. Les profils actuellement versionnes (`base`, `workstation`, `dev`, `home`, `vps`, `serveur`, `legacy`) suffisent-ils, ou faut-il ajouter `laptop`, `desktop`, `minimal` ?
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

16. L'import Mercurial -> Git de `/etc` via `hg-fast-export` est-il suffisant, ou faut-il garder une procedure manuelle de verification avant execution reelle ?
17. Faut-il conserver `/etc/.hg` durablement comme archive locale apres import, ou prevoir une etape manuelle de retrait plus tard ?
18. Souhaites-tu encadrer chaque role par un commit avant/apres comme `infra-deploy`, ou seulement le debut et la fin d'un run complet ?

## Modernisation

19. Quelle distribution cible minimale faut-il supporter aujourd'hui : Ubuntu 20.04, 22.04, 24.04, Debian 12, Debian 13 ?
20. Les roles Docker externes `infra-deploy` (`docker_dockerce_setup`, `docker_dockercompose_setup`) doivent-ils rester la reference pour `dev.list` et `serveur.list` ?
21. Docker Compose doit-il rester installe via le role `docker_dockercompose_setup` actuel, ou faut-il moderniser la source `infra-deploy` vers le plugin Compose ?
22. Les roles obsoletes (`keepassx`, `kpcli`, `rambox`, `teamviewer`, `terraform 0.6`, `ocsinventory`, ancien `docker-install`) doivent-ils etre archives, gardes en `legacy.list`, ou supprimes plus tard ?

## Alignement avec infra-deploy

23. `run_role.yml` et `run` existent maintenant. Souhaites-tu garder durablement `play.sh` comme compatibilite, ou le deprecier rapidement ?
24. Les fichiers `*.list` doivent-ils devenir le seul chemin recommande, ou garder des playbooks par profil en plus ?
25. Souhaites-tu une infra de test Docker pour ce depot, ou le cout n'est pas justifie pour des postes personnels ?
26. Comment veux-tu tester les roles `become` en local : sudo avec mot de passe, sudoers temporaire, VM de test, ou uniquement syntax-check depuis le poste courant ?

## Ma recommandation par defaut

Sans reponse contraire, je partirais sur ces hypotheses :

- depot personnel multi-profils, pas seulement workstation;
- utilisateur parametrable mais valeur par defaut `cedric`;
- `~/manuel.sh` conserve et officialise;
- `etckeeper` remplace Mercurial direct;
- `run` + `run_role.yml` + `*.list` ajoutes avant toute refonte de role;
- `workstation.list` porte Syncthing, `dev.list` porte Claude et Codex;
- Docker vient de `infra-deploy` pour `dev.list` et `serveur.list`, sans copie locale;
- toute tache doit conserver une semantique `changed` explicite en check mode;
- roles historiques gardes dans `legacy.list` tant qu'ils n'ont pas ete explicitement abandonnes.
