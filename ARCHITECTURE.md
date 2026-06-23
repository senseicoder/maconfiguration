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

Le coeur historique est `run.yml`. Il definit `compte`, `basedir` et `module_lang`, puis applique une sequence de roles avec des tags. Certains roles prennent des variables inline (`vcssource`, `vcsdestdir`) pour generer des actions de checkout/clone.

Le point d'entree cible est maintenant `run` + `run_role.yml`, inspire d'`infra-deploy`. `run_role.yml` joue un seul role, cree `~/manuel.sh` sans l'ecraser, et expose des handlers communs. `run` lance en check mode par defaut et sait jouer un role, une liste ou le playbook legacy.

## Flux d'execution actuel

1. Le poste cible doit etre accessible localement ou en SSH.
2. `setup.sh` peut installer les prerequis minimaux, mais il est ancien et contient encore des operations interactives (`cpan`) ou specifiques (`svn.epiconcept.fr`, `sshagent routes direct`).
3. `play.sh` lance `ansible-playbook -i hosts --ask-become-pass run.yml`.
4. `run.yml` applique les roles dans un ordre unique, module par tags, ou `run_role.yml` applique un seul role via `./run role ROLE`.
5. `manuel-install` cree `~/manuel.sh`; plusieurs roles y ajoutent des commandes lorsque l'automatisation directe n'est pas fiable.
6. `etc-init` et `etc-commit` encadrent partiellement les changements systeme via Mercurial dans `/etc`.

Ce flux est simple, mais il ne separe pas encore clairement les profils de machines, les prerequis, les phases interactives et les roles rejouables individuellement.

## Inventaire et variables

L'inventaire est `hosts`, avec deux groupes visibles : `maison` et `epiconcept`. Le groupe `epiconcept` est vide. Les hosts sont des noms de machines et quelques adresses IP avec `ansible_user=cedric`.

Les variables globales sont dans `run.yml` :

- `compte: cedric`
- `basedir: /home/{{ compte }}`
- `module_lang: fr_FR.UTF-8`

Quelques roles ont un `defaults/main.yml` : `bash-init`, `claude-init`, `keepassx-install`, `rambox-install`, `spotify-install`, `sublimtext-install`, `teamviewer-install`, `terraform-install`. La majorite des roles n'ont pas de defaults, donc les variables attendues ne sont pas documentees localement au role.

## Roles par domaine

### Base systeme

- `apt-init` : installe `aptitude`, ajoute le depot Epiconcept, fait un upgrade complet.
- `apt-paquets` : installe un gros lot de paquets poste de travail/dev/LAMP.
- `ubuntu-cleanup` : supprime les dossiers utilisateur Ubuntu par defaut.
- `linux-security` : force `UseRoaming no` dans `/etc/ssh/ssh_config`; utile historiquement, probablement obsolete sur distributions recentes.
- `clamav-install` : installe `clamav` et configure `freshclam`.
- `dossiers-init` : cree des repertoires `/home/dossiers`, `/home/epiconcept`, `/home/nas`, `/home/freebox`.

### Controle de `/etc`

- `etc-init` : installe Mercurial, initialise `/etc/.hg`, fait `addremove` et commit initial.
- `etc-commit` : commit final de `/etc`.

Ce mecanisme est utile mais inferieur au modele `infra-deploy` actuel : il est couple a Mercurial, duplique la logique de commit, et ne fournit pas de module dedie avec sortie claire. Le `todo.rst` mentionne deja un passage a `etckeeper`.

### Shell et environnement utilisateur

- `bash-init` : cree `~/.bashrc.d`, deploie `~/.bash_aliases` et des fragments `confd_*`.
- `bash-completion` : deploie `~/.bash_completion`.
- `bin-init` : role quasi vide, garde des notes autour de `~/bin`.
- `mercurial-install` : installe/configure Mercurial pour l'utilisateur et root.
- `git-install` : installe Git, configure ignore global et `git config --global`.
- `auth-init` : ajoute des cles de host CSoft dans `~/.ssh/known_hosts`.
- `ssh-auth` : genere une cle SSH et appelle `~/bin/sshagent upkey`; role non appele dans `run.yml`.
- `ssh` : modele de configuration SSH non appele dans `run.yml`.

### Depots et code

- `svn-install` : installe Subversion et configure le client.
- `svn-deploy` : cree le dossier cible, teste `svn info`, ajoute une commande `svn co` ou `svn up` dans `~/manuel.sh`.
- `git-deploy` : si le dossier cible est absent, ajoute une commande `git clone` dans `~/manuel.sh`.

Le depot a donc choisi implicitement une strategie prudente : ne pas cloner/puller automatiquement certains depots sensibles aux credentials, mais produire une liste de commandes manuelles. Cette strategie est saine si elle est assumee comme interface officielle.

### Applications poste de travail

- `sublimtext-install` : depot Sublime Text, paquet, Package Control.
- `syncthing-install` : installe Syncthing, active `syncthing@cedric`, puis modifie la configuration via API REST.
- `claude-init` : installe Claude Code, lie la configuration et les skills depuis Syncthing, synchronise les dossiers `memory`.
- `guake-install` : installe Guake et cree une entree autostart.
- `cps-install` : installe les paquets CPS et configure NSS Firefox/Chrome.
- `mysql-shell-config` : installe `grc` et deploie `.my.cnf`/`.grcat`.
- `awscli-install` : installe AWS CLI dans un venv `/opt/awscli-venv`.
- `docker-install` : installe `docker.io`, telecharge `docker-compose` v1.24.0, ajoute l'utilisateur au groupe `docker`.
- `lamp-install` : installe un socle Apache/PHP/MySQL.

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
- Le mecanisme `~/manuel.sh` evite de cacher des echecs d'authentification ou des etapes qui dependent d'un contexte externe.
- `claude-init` est plus moderne que le reste : assertions explicites, prerequis verifies, logique Ansible pure pour une synchronisation delicate.
- Le controle de `/etc` existe deja, meme s'il merite une modernisation.

## Fragilites techniques

- L'utilisateur `cedric` et `/home/cedric` apparaissent directement dans plusieurs roles, notamment `syncthing-install`.
- Il n'y a pas de profils explicites : poste complet, poste minimal, serveur maison, laptop, VM, etc.
- Beaucoup de roles n'ont pas de `defaults/main.yml`, donc leurs contrats sont implicites.
- Les modules sont souvent appeles sous leur nom court (`apt`, `file`, `shell`) et les styles YAML sont heterogenes.
- `apt_key` et les depots avec cle globale sont des patterns vieillissants.
- Plusieurs checks utilisent `shell` + `grep` au lieu de modules ou commandes avec `creates`/`changed_when` plus stricts.
- Les handlers sont absents; les redemarrages sont faits inline ou pas formalises.
- La gestion `/etc` est dupliquee entre `etc-init` et `etc-commit`.
- `play.sh` execute directement; il n'y a pas de dry-run par defaut ni de lanceur par role comparable a `infra-deploy`.
- Certains roles contiennent des bugs probables ou de la dette syntaxique : espaces insécables dans des variables (`{{ item }}` dans `cps-install`, `{{ subl_path }}` dans `sublimtext-install`), `docker-compose` v1, `push.default matching`, `UseRoaming`, versions figees anciennes.

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

1. extraire les variables globales hors de `run.yml` et `run_role.yml`;
2. enrichir `run_role.yml` avec log et controle `/etc`;
3. stabiliser les listes de roles (`base.list`, `workstation.list`, `sync.list`, `dev.list`, `home.list`);
4. transformer `~/manuel.sh` en sortie documentee et idempotente;
5. remplacer Mercurial `/etc` par `etckeeper` ou un role dedie compatible avec l'existant;
6. ajouter `defaults/main.yml` a tous les roles actifs;
7. seulement ensuite, renommer ou decouper les roles.

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
