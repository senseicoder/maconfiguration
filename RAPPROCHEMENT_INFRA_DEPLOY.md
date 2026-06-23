# Rapprochement vers le modele infra-deploy

## Reference observee

`www/e/infra-deploy/CLAUDE.md` et un scan minimal de `www/e/infra-deploy/ansible` montrent un modele plus exploitable :

- structure `ansible/roles`, `group_vars`, `host_vars`, `vars`;
- inventaire externe ou separe;
- `run_role.yml` generique;
- wrapper `run` avec dry-run par defaut;
- fichiers `*.list` pour composer des sequences de roles;
- roles nommes par domaine et action;
- `defaults/main.yml` systematique;
- handlers centralises dans `run_role.yml`;
- roles generiques autour de l'execution : variables, log, controle `/etc`, flush handlers.

Le but n'est pas de copier le perimetre employeur. Le bon objectif est de reprendre les mecanismes d'exploitation qui rendent les roles rejouables, auditables et composables.

## Ecarts structurants

| Sujet | maconfiguration actuel | infra-deploy | Ecart utile |
|-------|------------------------|--------------|-------------|
| Entree principale | `run.yml` monolithique | `run_role.yml` generique | Jouer un role isole proprement |
| Composition | tags dans `run.yml` | fichiers `*.list` | Profils lisibles et versionnes |
| Variables | globales dans `run.yml`, chemins durs | `group_vars`, `host_vars`, `vars` | Contrats explicites par machine/profil |
| Roles | noms historiques `*-install`, `*-init` | prefixe domaine + action | Classification maintenable |
| Defaults | partiels | systematiques | Documentation locale des variables |
| Handlers | absents ou inline | centralises | Redemarrages coherents |
| Controle `/etc` | `etc-init` / `etc-commit` via etckeeper/Git | role generique + etckeeper | Encadrement commun avant/apres role |
| Lancement | execution directe | dry-run par defaut | Exploitation plus prudente |
| Tests | pas d'infra de test | Docker de test | Rejouabilite sans machine reelle |
| Manuel | `~/manuel.sh` implicite | roles plus autonomes | Formaliser ou reduire le manuel |

## Cible proposee pour maconfiguration

```
.
  ansible.cfg
  inventory/
    hosts.yml ou hosts.ini
  group_vars/
    all.yml
    workstation.yml
    home.yml
    server.yml
  host_vars/
    mnementh6.yml
    ramoth.yml
  vars/
    debian_12.yml
    ubuntu_24.yml
  run
  run_role.yml
  base.list
  workstation.list
  dev.list
  sync.list
  home.list
  server_home.list
  legacy.list
  roles/
```

Cette structure peut etre ajoutee progressivement sans deplacer immediatement tous les fichiers.

Sur la branche `vers-deploy-et-audela`, `run`, `run_role.yml` et les listes sont maintenant versionnes. Le wrapper ajoute aussi le chemin de roles `/home/cedric/www/e/infra-deploy/ansible/roles` a `ANSIBLE_ROLES_PATH` quand il existe. Cela permet d'utiliser un role `infra-deploy` sans le copier dans ce depot.

## Profils de roles proposes

### `base.list`

Socle commun poste/serveur :

```
base_apt_setup
base_apt_packages
base_etc_control_setup
base_shell_conf
base_git_install
base_security_conf
```

Equivalent initial sans renommage :

```
apt-init
apt-paquets
etc-init
bash-init
bash-completion
git-install
etc-commit
```

### `workstation.list`

Poste graphique :

```
ubuntu-cleanup
guake-install
sublimtext-install
syncthing-install
cps-install
mysql-shell-config
clamav-install
```

### `dev.list`

Outils dev :

```
svn-install
git-install
docker_dockerce_setup
docker_dockercompose_setup
lamp-install
awscli-install
claude-init
codex-init
```

Docker est volontairement fourni par `infra-deploy` dans ce profil, via `docker_dockerce_setup` et `docker_dockercompose_setup`. L'ancien role local `docker-install` reste conserve en `legacy.list`.

### `sync.list`

Le profil `sync.list` n'est plus le porteur principal de Syncthing, Claude ou Codex :

```
# Syncthing est porte par workstation.list.
# Claude et Codex sont portes par dev.list.
```

### `home.list`

Specificites maison :

```
dossiers-init
```

### `legacy.list`

Roles conserves mais hors chemin nominal :

```
keepassx-install
kpcli-install
docker-install
rambox-install
spotify-install
teamviewer-install
ocsinventory-install
terraform-install
openfortissl-install
ssh
ssh-auth
linux-security
```

### `vps.list`

Socle minimal pour un VPS personnel sans poste graphique :

```
etc-init
apt-init
bash-init
bash-completion
cron-conf
auth-init
git-install
linux-security
etc-commit
```

### `serveur.list`

Serveur personnel avec Docker via roles externes :

```
etc-init
apt-init
bash-init
bash-completion
cron-conf
auth-init
git-install
linux-security
docker_dockerce_setup
docker_dockercompose_setup
etc-commit
```

## Plan de migration recommande

### Phase 1 — rendre l'exploitation lisible

Ajouter sans changement fonctionnel :

- `run_role.yml` minimal qui applique `role` — fait;
- un wrapper `run` inspire d'`infra-deploy`, dry-run par defaut — fait;
- des fichiers `*.list` initiaux — fait;
- `group_vars/all.yml` contenant `compte`, `basedir`, `module_lang`;
- une documentation de `~/manuel.sh`.

Risque faible : on ne change pas les roles, on change seulement les points d'entree.

### Phase 2 — encadrer les roles

Ajouter :

- role `generic_log`;
- role `generic_etc_control` autour du backend etckeeper existant;
- `defaults/main.yml` vide ou documente pour tous les roles actifs;
- handlers centralises si besoin.

Risque moyen : le controle `/etc` touche le systeme. A faire d'abord sur une machine non critique ou en check mode quand possible.

### Phase 3 — sortir les specificites machine

Deplacer vers variables :

- nom utilisateur et home;
- devices Syncthing;
- cle API Syncthing ou chemin de lecture;
- chemins `/home/nas`, `/home/freebox`, `/home/epiconcept`;
- depots Git/SVN a preparer;
- liste de paquets par profil.

Risque moyen : c'est la phase qui revele les dependances implicites.

### Phase 4 — moderniser les roles actifs

Priorites :

- remplacer `apt_key` par keyrings dedies;
- corriger les chemins durs `/home/cedric`;
- garantir que chaque tache indique `changed` quand cela a du sens, y compris en check mode;
- rendre les downloads idempotents et versionnes;
- remplacer Docker Compose v1 par le plugin Compose si c'est le choix actuel;
- corriger les espaces insécables dans `cps-install` et `sublimtext-install`;
- remplacer `push.default matching`;
- revoir `UseRoaming no`;
- isoler les paquets LAMP/dev/desktop en listes distinctes.

Risque variable selon les roles. A faire role par role avec dry-run et execution ciblee.

### Phase 5 — renommer et decouper

Ne renommer qu'une fois les profils stables. Exemple :

| Actuel | Cible possible |
|--------|----------------|
| `apt-init` | `base_apt_setup` |
| `apt-paquets` | `base_packages_install` ou `workstation_packages_install` |
| `bash-init` | `base_shell_conf` |
| `syncthing-install` | `sync_syncthing_setup` |
| `claude-init` | `sync_claude_conf` ou `dev_claude_setup` |
| `docker-install` | `dev_docker_setup` |
| `dossiers-init` | `home_mountpoints_setup` |
| `etc-init` / `etc-commit` | `base_etckeeper_setup` + `generic_etc_control` |

Le renommage doit etre accompagne d'une compatibilite temporaire dans les listes ou d'un mapping documente.

## Position directe

Le plus gros gain n'est pas dans la syntaxe Ansible. Il est dans la separation entre :

- le socle commun;
- les profils;
- les donnees personnelles synchronisees;
- les actions manuelles assumees;
- les roles historiques.

Une fois cette separation faite, la modernisation technique devient beaucoup moins risquee.

## Usage de roles externes

L'objectif n'est pas de vendoriser `infra-deploy`. Pour les besoins communs, comme Docker CE et Docker Compose, le wrapper `run` doit resoudre les roles via `ANSIBLE_ROLES_PATH`. Le depot garde ainsi une dependance locale explicite vers `infra-deploy`, mais evite la copie de roles et la divergence de maintenance.

Cette approche impose une vigilance particuliere : les roles externes doivent eux aussi respecter la semantique check mode, notamment pour les taches `shell`/`command`. Si un role externe ne le fait pas, il faut corriger le role source dans `infra-deploy` plutot que masquer le probleme ici.
