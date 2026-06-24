# Architecture de maconfiguration

## Objet

`maconfiguration` automatise la remise en etat exploitable de postes de travail personnels, principalement Ubuntu, avec quelques ambitions serveur. Le depot installe des paquets, configure des outils utilisateur, initialise certains repertoires, gere une partie de `/etc`, et prepare des operations qui restent volontairement ou historiquement manuelles.

Le projet n'est pas aujourd'hui une plateforme Ansible generaliste. C'est un playbook personnel, efficace par accumulation, mais avec des implicites forts : utilisateur `cedric`, home `/home/cedric`, reseaux et machines connus, Syncthing deja synchronise pour certains roles, acces SSH/GitHub/SVN preexistants selon les cas.

## Vue d'ensemble

```
.
  README.md                  # installation rapide et contraintes historiques
  setup.sh                   # bootstrap local ancien : ansible, svn, cpan
  play.sh                    # wrapper ansible-playbook sur run.yml
  run                        # wrapper moderne, dry-run par defaut
  run_role.yml               # playbook generique pour jouer un role
  run.yml                    # playbook monolithique, ordre principal des roles
  *.list                     # profils initiaux de roles
  hosts                      # inventaire local personnel
  ansible.cfg.off            # configuration Ansible non active
  state.d/                   # scripts d'etat hors roles Ansible
  todo.rst                   # backlog historique, notes d'exploitation
  todo/                      # essais, roles non integres, archives
  roles/                     # roles Ansible
```

Le coeur historique est `run.yml`. Il applique une sequence de roles avec des tags et s'appuie maintenant sur `group_vars/all.yml` pour les variables globales. Certains roles prennent des variables inline (`vcssource`, `vcsdestdir`) pour piloter des checkouts/clones.

Le point d'entree cible est maintenant `run` + `run_role.yml`, inspire d'`infra-deploy`. `run_role.yml` joue un seul role et expose des handlers communs. `run` lance en check mode par defaut et sait jouer un role, une liste ou le playbook legacy.

Sur la branche `vers-deploy-et-audela`, ce point d'entree est versionne et les listes deviennent l'interface de migration. Le wrapper resout les roles locaux et peut aussi utiliser des roles `infra-deploy` sans les copier via `ANSIBLE_ROLES_PATH`, avec `/home/cedric/www/e/infra-deploy/ansible/roles` comme chemin externe par defaut.

## Flux d'execution actuel

1. Le poste cible doit etre accessible localement ou en SSH.
2. `setup.sh` peut installer les prerequis minimaux, mais il est ancien et contient encore des operations interactives (`cpan`) ou specifiques (`svn.epiconcept.fr`, `sshagent routes direct`).
3. `play.sh` lance `ansible-playbook -i hosts --ask-become-pass run.yml`.
4. `run.yml` applique les roles dans un ordre unique, module par tags, ou `run_role.yml` applique un seul role via `./run role ROLE`.
5. `etc-init` et `etc-commit` encadrent les changements systeme via etckeeper/Git dans `/etc`, avec tentative d'import de l'ancien historique Mercurial si present.

Ce flux est simple, mais il ne separe pas encore clairement les profils de machines, les prerequis, les phases interactives et les roles rejouables individuellement.

Le flux en cours d'officialisation est :

```
./run role ROLE              # check mode + diff
./run role ROLE run          # execution reelle + diff
./run list base.list         # check mode sequentiel
./run list base.list run     # execution reelle sequentielle
./run legacy                 # check mode de run.yml
```

Le mot-cle `run` est volontairement explicite. Sans lui, `run` ajoute `-C -D` a `ansible-playbook`.

## Inventaire et variables

L'inventaire est `hosts`, avec deux groupes visibles : `maison` et `epiconcept`. Le groupe `epiconcept` est vide. Les hosts sont des noms de machines et quelques adresses IP avec `ansible_user=cedric`.

Les variables globales sont dans `group_vars/all.yml` :

- `compte: cedric`
- `basedir: /home/{{ compte }}`
- `module_lang: fr_FR.UTF-8`

Quelques roles ont un `defaults/main.yml` : `bash-init`, `bin-init`, `claude-init`, `keepassx-install`, `rambox-install`, `spotify-install`, `sublimtext-install`, `syncthing-install`, `teamviewer-install`, `terraform-install`. La majorite des roles n'ont pas encore de defaults, donc les variables attendues ne sont pas documentees localement au role.

## Roles par domaine

### Base systeme

- `apt-init` : installe `aptitude`, ajoute le depot Epiconcept, fait un upgrade complet.
- `apt-paquets` : installe le socle CLI commun.
- `workstation-paquets` : installe les paquets graphiques, media, docs et montages poste utilisateur.
- `dev-paquets` : installe les paquets de developpement et LAMP.
- `ubuntu-cleanup` : supprime les dossiers utilisateur Ubuntu par defaut.
- `cron-conf` : deploie `/etc/cron.d/{{ compte }}` depuis un template parametre par `compte` et `basedir`.
- `linux-security` : force `UseRoaming no` dans `/etc/ssh/ssh_config`; utile historiquement, maintenant conserve hors chemin nominal.
- `clamav-install` : installe `clamav` et configure `freshclam`.
- `dossiers-init` : cree des repertoires `/home/dossiers`, `/home/epiconcept`, `/home/nas`, `/home/freebox`.

### Controle de `/etc`

- `etc-init` : installe `etckeeper` et Git, configure `VCS="git"`, et tente d'importer l'historique Mercurial existant via `hg-fast-export` si `/etc/.hg` existe et `/etc/.git` est absent.
- `etc-commit` : commit final de `/etc` via `etckeeper` si un depot Git existe et contient des changements.

Ce mecanisme garde les noms historiques des roles pour limiter le changement dans les listes, mais le backend cible est maintenant etckeeper/Git. L'ancien depot Mercurial de `/etc` est conserve comme source d'import et archive locale.

### Shell et environnement utilisateur

- `bash-init` : deploie `~/.bash_aliases` depuis le modele importe du poste courant.
- `bash-completion` : deploie `~/.bash_completion`.
- `bin-init` : gere le checkout SVN racine de `~/bin` depuis `ScriptsBash`, verifie son origine et teste les mises a jour distantes en check mode. Les depots Git imbriques dans `~/bin` restent geres separement.
- `mercurial-install` : installe/configure Mercurial pour l'utilisateur et root; role conserve hors chemin nominal.
- `git-install` : installe Git, configure ignore global et `git config --global`.
- `auth-init` : ajoute des cles de host CSoft dans `~/.ssh/known_hosts`.
- `ssh-auth` : genere une cle SSH et appelle `~/bin/sshagent upkey`; role non appele dans `run.yml`.
- `ssh` : modele de configuration SSH non appele dans `run.yml`.

### Depots et code

- `svn-install` : installe Subversion si absent et configure le client.
- `manuel-install` : ancien createur de `~/manuel.sh`, conserve hors chemin nominal.
- `svn-deploy` : ancien mecanisme generique, garde hors listes simples, qui ajoute une commande `svn co` ou `svn up` dans `~/manuel.sh`.
- `git-deploy` : gere directement un clone Git parametre par `vcssource` et `vcsdestdir`, verifie l'origine distante, annonce les depots absents ou en retard en check mode, et ne force pas les modifications locales.

Le depot reduit progressivement les actions manuelles : `bin-init` et `git-deploy` deployent maintenant directement leurs depots. Les anciens mecanismes generiques `svn-deploy` et `manuel-install` restent disponibles comme archives, mais ne sont plus appeles par `run.yml` ni par les listes.

### Applications poste de travail

- `sublimtext-install` : depot Sublime Text, paquet, Package Control.
- `syncthing-install` : installe Syncthing, active `syncthing@{{ compte }}`, puis modifie la configuration via API REST. Dans les profils, il appartient maintenant a `workstation.list` et `raspi.list`.
- `claude-init` : installe Claude Code, lie la configuration et les skills depuis Syncthing, synchronise les dossiers `memory`. Dans les profils, il appartient maintenant a `dev.list`.
- `codex-init` : installe Codex si absent. Le role annonce en check mode que l'installation serait effectuee, puis n'execute le script distant qu'en mode reel.
- `guake-install` : installe Guake et cree une entree autostart.
- `cps-install` : installe les paquets CPS et configure NSS Firefox/Chrome.
- `mysql-shell-config` : installe `grc` et deploie `.my.cnf`/`.grcat`.
- `awscli-install` : installe AWS CLI dans un venv `/opt/awscli-venv`.
- `docker-install` : installe `docker.io`, telecharge `docker-compose` v1.24.0, ajoute l'utilisateur au groupe `docker`.
- `lamp-install` : installe un socle Apache/PHP/MySQL.

Pour les profils modernes, Docker ne doit plus utiliser `docker-install` par defaut. `dev.list` et `serveur.list` utilisent les roles externes `docker_dockerce_setup` et `docker_dockercompose_setup` fournis par `infra-deploy`, sans copie locale.

## Profils versionnes

- `base.list` : socle commun poste/serveur, avec controle `/etc` via etckeeper, APT, shell, cron, auth et Git.
- `workstation.list` : delta poste graphique et outils utilisateur, avec paquets desktop/media/docs et Syncthing.
- `raspi.list` : delta Raspberry Pi personnel sans poste graphique, avec Syncthing.
- `dev.list` : delta outils de developpement et LAMP, avec SVN, Docker via `infra-deploy`, AWS CLI, Claude et Codex.
- `home.list` : delta specificites maison.
- `vps.list` : delta VPS personnel sans poste graphique; actuellement aucun role specifique en plus de `base.list`.
- `serveur.list` : delta serveur personnel avec Docker via `infra-deploy`.
- `legacy.list` : roles conserves hors chemin nominal, dont l'ancien `docker-install`.

`sync.list` reste present mais n'est plus le profil porteur de Syncthing, Claude ou Codex : Syncthing est rattache a `workstation.list` et `raspi.list`, Claude et Codex a `dev.list`.

### Roles obsoletes ou a isoler

Plusieurs roles sont commentes dans `run.yml` ou portent des versions anciennes :

- `keepassx-install`, `kpcli-install`
- `rambox-install`
- `spotify-install`
- `teamviewer-install`
- `ocsinventory-install`
- `terraform-install` en version 0.6.16
- `openfortissl-install` non appele

Ils doivent rester lisibles, mais ne devraient pas peser sur le chemin nominal tant que leur statut n'est pas tranche.

## Points solides

- Le depot encode beaucoup de connaissance d'exploitation reelle, pas seulement une liste de paquets.
- L'ordre de `run.yml` raconte le bootstrap attendu : manuel, VCS, shell, sync, outils de travail.
- Le mecanisme `~/manuel.sh` reste un filet historique pour certaines actions non automatisees, mais le chemin nominal doit privilegier des roles capables de verifier explicitement leurs prerequis.
- `claude-init` est plus moderne que le reste : assertions explicites, prerequis verifies, logique Ansible pure pour une synchronisation delicate.
- Le controle de `/etc` existe deja, meme s'il merite une modernisation.

## Fragilites techniques

- L'utilisateur `cedric` et `/home/cedric` apparaissent encore directement dans certains roles, templates ou commentaires historiques; les roles actifs doivent continuer a migrer vers `compte` et `basedir`.
- Les profils principaux existent, avec `base.list` comme socle et les autres listes comme deltas. Il reste a valider leur composition sur des machines reelles.
- Beaucoup de roles n'ont pas de `defaults/main.yml`, donc leurs contrats sont implicites.
- Les modules sont souvent appeles sous leur nom court (`apt`, `file`, `shell`) et les styles YAML sont heterogenes.
- `apt_key` et les depots avec cle globale sont des patterns vieillissants.
- Plusieurs checks utilisent `shell` + `grep` au lieu de modules ou commandes avec `creates`/`changed_when` plus stricts.
- Toute tache doit reporter un changement quand cela a du sens, y compris en check mode. Les taches de collecte d'etat doivent expliciter `changed_when: false` et, si necessaire, `check_mode: false`. Les taches `shell`/`command` qui feraient une modification doivent avoir une modelisation claire du `changed` en check mode.
- Les handlers sont absents; les redemarrages sont faits inline ou pas formalises.
- La gestion `/etc` reste repartie entre `etc-init` et `etc-commit`, mais elle utilise maintenant etckeeper/Git.
- `play.sh` execute encore directement le legacy; le chemin recommande est maintenant `run`, qui fournit le dry-run par defaut et le lancement par role.
- Certains roles contiennent des bugs probables ou de la dette syntaxique : espaces insécables dans des variables (`{{ item }}` dans `cps-install`, `{{ subl_path }}` dans `sublimtext-install`), `docker-compose` v1 dans l'ancien role local, `UseRoaming`, versions figees anciennes.

## Architecture cible recommandee

Sans changer le fond personnel du projet, la cible la plus utile est :

```
.
  ansible.cfg
  inventory/
  group_vars/
  host_vars/
  vars/
  run                 # wrapper dry-run par defaut, deja present
  run_role.yml        # joue un role avec encadrement commun, deja present
  *.list              # profils de roles ordonnes
  roles/
```

La migration doit rester progressive. Le premier gain n'est pas de renommer tous les roles, mais de rendre l'exploitation plus previsible :

1. extraire les variables globales hors de `run.yml` et `run_role.yml` — fait;
2. stabiliser les listes de roles (`base.list` comme socle, puis `workstation.list`, `raspi.list`, `dev.list`, `home.list`, `vps.list`, `serveur.list`, `legacy.list` comme deltas) — premiere passe faite;
3. sortir `~/manuel.sh` du chemin nominal et documenter les derniers cas historiques — fait;
4. finaliser les chemins durs actifs (`bash-init`, `bash-completion`, roles workstation/dev restants);
5. ajouter `defaults/main.yml` a tous les roles actifs;
6. enrichir `run_role.yml` avec log et controle `/etc`;
7. valider l'import de l'historique Mercurial `/etc` vers etckeeper/Git sur une autre machine;
8. seulement ensuite, renommer ou decouper les roles.

## Decision d'architecture principale

Le choix a clarifier est le perimetre exact : ce depot doit-il rester un automate de postes personnels avec quelques roles serveur, ou devenir l'equivalent personnel d'une plateforme d'infra multi-profils ?

Ma recommandation : viser une plateforme personnelle multi-profils, mais garder une ligne nette entre :

- `workstation_*` : poste graphique principal;
- `dev_*` : environnement de developpement;
- `sync_*` : Syncthing et donnees synchronisees;
- `home_*` : specificites maison/NAS/freebox;
- `base_*` : socle commun Debian/Ubuntu;
- `legacy_*` : roles conserves mais non joues par defaut.

Cela rapproche le projet d'`infra-deploy` sans importer son vocabulaire employeur ni son inventaire.

## Validation locale actuelle

Les syntax-checks de toutes les listes `*.list` passent avec le wrapper.

Les checks locaux avec `ANSIBLE_INVENTORY=localhost, ./run list ... -c local` sont bien lances en check mode (`-C -D`). Sur le poste courant, ils sont partiellement bloques par `sudo: a password is required` pour les roles avec `become`. Les roles utilisateur s'executent et produisent des diffs en check mode. Les validations ciblees recentes couvrent notamment `bin-init`, `git-deploy`, `cron-conf`, `syncthing-install`, `base.list`, `workstation.list`, `dev.list`, `raspi.list`, `serveur.list` et `vps.list`.
