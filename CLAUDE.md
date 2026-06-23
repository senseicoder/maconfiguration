# maconfiguration — guide pour Claude

## Perimetre

Ce depot automatise le deploiement de postes de travail personnels et de quelques usages serveur. Il est ecrit en Ansible et cible surtout Ubuntu/Debian.

L'utilisateur principal est actuellement `cedric`. Ne pas supposer que le projet est multi-utilisateur tant que les variables et chemins durs n'ont pas ete corriges.

## Regle de travail

Ne pas modifier le comportement sans demande explicite. Pour une analyse ou une documentation, creer uniquement des fichiers racine ou mettre a jour les documents demandes.

Le depot contient de la dette historique utile. Ne pas supprimer un role parce qu'il semble obsolete : le documenter, l'isoler ou demander confirmation.

## Structure actuelle

```
run.yml       # playbook principal, sequence unique de roles
run_role.yml  # playbook generique pour jouer un role
run           # wrapper moderne, check mode par defaut
play.sh       # wrapper ansible-playbook sur hosts/run.yml
setup.sh      # bootstrap ancien du poste local
hosts         # inventaire personnel
*.list        # listes initiales de roles par profil
roles/        # roles Ansible
state.d/      # scripts d'etat hors roles
todo.rst      # backlog et notes historiques
todo/         # essais et elements non integres
```

## Execution actuelle

```bash
./play.sh
./play.sh --tags apt-paquets
ansible-playbook -i hosts --ask-become-pass run.yml
```

`play.sh help` liste les hosts et tags.

Nouveau chemin recommande :

```bash
./run role bash-init          # dry-run par defaut
./run role bash-init run      # execution reelle
./run list base.list          # dry-run sequentiel
./run list base.list run      # execution reelle sequentielle
./run list dev.list           # dry-run des outils dev, roles infra-deploy inclus
./run legacy                  # dry-run de run.yml
./run legacy run              # execution reelle de run.yml
```

`run_role.yml` joue un seul role et expose les handlers communs; il ne cree plus `~/manuel.sh`.

Le wrapper ajoute `-C -D` par defaut. Le mot-cle `run`, place juste apres `role`, `list` ou `legacy`, retire seulement `-C`; le diff reste actif. Exemple : `./run list base.list run`.

Quand `/home/cedric/www/e/infra-deploy/ansible/roles` existe, `run` l'ajoute a `ANSIBLE_ROLES_PATH`. Cela permet d'appeler des roles `infra-deploy` sans les copier, par exemple `docker_dockerce_setup` et `docker_dockercompose_setup`.

## Variables globales actuelles

Dans `run.yml` :

```yaml
compte: cedric
basedir: "/home/{{ compte }}"
module_lang: fr_FR.UTF-8
```

Ces variables sont le contrat implicite de nombreux roles. Certains roles utilisent encore `/home/cedric` en dur.

## Convention cible inspiree d'infra-deploy

A terme, preferer :

```
inventory/
group_vars/
host_vars/
vars/
run
run_role.yml
*.list
roles/
```

Chaque role actif devrait avoir :

```
role_name/
  tasks/main.yml
  defaults/main.yml
  files/
  templates/
```

Les variables d'un role doivent etre prefixees par le nom du role ou par son domaine. Exemple : `claude_init_version`, `sync_syncthing_devices`, `base_user_name`.

## Nommage cible des roles

Le depot actuel utilise surtout `{outil}-install` et `{domaine}-init`. Ne pas renommer mecaniquement.

Pour les nouveaux roles ou les refontes, viser :

| Prefixe | Usage |
|---------|-------|
| `base_` | socle commun Debian/Ubuntu |
| `workstation_` | poste graphique et ergonomie utilisateur |
| `dev_` | outils de developpement |
| `sync_` | Syncthing, donnees synchronisees, liens vers Sync |
| `home_` | specificites maison/NAS/freebox |
| `server_` | services serveur personnels |
| `legacy_` | roles conserves mais non joues par defaut |
| `generic_` | roles techniques d'encadrement : log, vars, controle `/etc` |

Actions recommandees : `_setup`, `_conf`, `_install`, `_deploy`.

## Roles actifs importants

- `manuel-install` : cree `~/manuel.sh`, interface actuelle pour les actions manuelles.
- `etc-init` / `etc-commit` : controle `/etc` via etckeeper/Git, avec tentative d'import de l'ancien historique Mercurial si present.
- `apt-init` / `apt-paquets` : socle APT et paquets CLI communs.
- `workstation-paquets` : paquets desktop/media/docs.
- `dev-paquets` : paquets dev et LAMP.
- `bash-init` / `bash-completion` : shell utilisateur.
- `auth-init` : known_hosts CSoft.
- `svn-install` : installation/configuration du client SVN. `bin-init` l'utilise comme dependance pour gerer directement le checkout SVN de `~/bin`.
- `git-install` / `git-deploy` : configuration Git et clone/update directs des depots parametres.
- `syncthing-install` : installation et configuration API Syncthing.
- `claude-init` : installation Claude Code et liens vers Syncthing.
- `codex-init` : installation Codex, avec annonce de changement correcte en check mode.
- `docker_dockerce_setup` / `docker_dockercompose_setup` : roles Docker externes venant d'`infra-deploy`, utilises par `dev.list` et `serveur.list`.
- `docker-install`, `lamp-install`, `awscli-install`, `mysql-shell-config`, `cps-install` : outils de travail. `docker-install` est maintenant legacy pour les profils.
- `linux-security` : role historique `UseRoaming no`, conserve en legacy.

## Profils actuels

- `base.list` : socle commun.
- `workstation.list` : poste graphique, avec paquets desktop/media/docs et `syncthing-install`.
- `dev.list` : outils dev et LAMP, avec Docker via `infra-deploy`, `claude-init` et `codex-init`.
- `home.list` : specificites maison.
- `vps.list` : socle VPS minimal.
- `serveur.list` : VPS/serveur avec Docker.
- `legacy.list` : roles conserves hors chemin nominal.
- `sync.list` : reserve, ne porte plus Syncthing/Claude/Codex.

## Patterns locaux a respecter

- `~/manuel.sh` est un filet historique pour ce qui depend de credentials ou d'un etat externe. Preferer un role qui verifie explicitement ses prerequis et echoue proprement.
- Les roles qui modifient le systeme doivent utiliser `become: true`.
- Les roles qui modifient l'utilisateur doivent utiliser `compte` et `basedir`, pas `/home/cedric`.
- Les roles qui telechargent depuis Internet doivent verifier l'idempotence (`creates`, fichier versionne, ou checksum quand disponible).
- Les roles qui dependent de Syncthing doivent echouer explicitement avec `assert` si le dossier attendu n'est pas synchronise.
- Eviter les nouveaux usages de `apt_key`; preferer un keyring dedie et `signed-by`.
- Les taches doivent reporter une modification quand cela a du sens, en execution reelle comme en check mode. Les collectes d'etat doivent utiliser `changed_when: false`; les collectes necessaires au check mode doivent ajouter `check_mode: false`. Une action `shell`/`command` qui ferait une modification doit avoir une strategie explicite pour annoncer `changed` en check mode sans executer l'action.

## Points d'attention avant modification

- Ne pas casser le bootstrap d'un poste vierge : Git, SVN, SSH, Syncthing et Claude ont des dependances circulaires partielles.
- `syncthing-install` contient une liste de devices personnelle et lit `/home/cedric/.config/bin_ss`.
- `claude-init` depend de `~/Sync/Central/.stfolder` et de dossiers synchronises.
- `codex-init` execute un script distant seulement hors check mode; en check mode il doit annoncer l'installation prevue si `codex` est absent.
- Les roles Docker des profils `dev.list` et `serveur.list` viennent d'`infra-deploy`; corriger la source externe si leur semantique Ansible est insuffisante.
- `git-deploy` deploie directement les depots Git parametres par `vcssource` et `vcsdestdir`. `svn-deploy` reste l'ancien mecanisme generique vers `~/manuel.sh`; `bin-init` fait exception pour `~/bin`, qu'il checkout/update directement depuis SVN.
- `etc-init` garde le nom historique mais utilise etckeeper/Git; l'import Mercurial doit rester prudent et ne pas supprimer `/etc/.hg`.
- Plusieurs roles sont obsoletes mais peuvent documenter un besoin ancien.

## Mode d'evolution recommande

1. Garder `play.sh`/`run.yml` comme compatibilite legacy.
2. Utiliser `run`/`run_role.yml` pour les evolutions role par role.
3. Sortir les variables dans `group_vars`/`host_vars`.
4. Ajouter `defaults/main.yml` aux roles actifs.
5. Remplacer ou isoler les roles obsoletes.
6. Moderniser les modules et depots APT.
7. Renommer les roles seulement quand le flux d'exploitation est stable.

## Tests raisonnables

Avant une modification de role :

```bash
ansible-playbook -i hosts run.yml --syntax-check
ansible-playbook -i hosts run.yml --list-tags
ansible-playbook -i hosts run.yml --tags <tag> --check --diff
ANSIBLE_INVENTORY=localhost, ./run list base.list -c local
ANSIBLE_INVENTORY=localhost, ./run list workstation.list -c local
```

Le wrapper `run` applique deja un dry-run par defaut comme dans `infra-deploy`. Les tests locaux avec `become` demandent un mot de passe sudo ou une configuration sudo adaptee; sans cela, les roles systeme echouent avec `sudo: a password is required`.
