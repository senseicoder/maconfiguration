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
./run legacy                  # dry-run de run.yml
./run legacy run              # execution reelle de run.yml
```

`run_role.yml` cree `~/manuel.sh` avec `force: false`, donc il ne doit pas ecraser un fichier manuel existant.

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
- `etc-init` / `etc-commit` : controle `/etc` via Mercurial.
- `apt-init` / `apt-paquets` : socle APT et paquets.
- `bash-init` / `bash-completion` : shell utilisateur.
- `auth-init` : known_hosts CSoft.
- `svn-install` / `svn-deploy` : configuration SVN et commandes manuelles de checkout/update.
- `git-install` / `git-deploy` : configuration Git et commandes manuelles de clone.
- `syncthing-install` : installation et configuration API Syncthing.
- `claude-init` : installation Claude Code et liens vers Syncthing.
- `docker-install`, `lamp-install`, `awscli-install`, `mysql-shell-config`, `cps-install` : outils de travail.

## Patterns locaux a respecter

- `~/manuel.sh` est une sortie volontaire pour ce qui depend de credentials ou d'un etat externe. Si un role ne peut pas faire une action proprement, ajouter une commande idempotente a ce fichier est acceptable.
- Les roles qui modifient le systeme doivent utiliser `become: true`.
- Les roles qui modifient l'utilisateur doivent utiliser `compte` et `basedir`, pas `/home/cedric`.
- Les roles qui telechargent depuis Internet doivent verifier l'idempotence (`creates`, fichier versionne, ou checksum quand disponible).
- Les roles qui dependent de Syncthing doivent echouer explicitement avec `assert` si le dossier attendu n'est pas synchronise.
- Eviter les nouveaux usages de `apt_key`; preferer un keyring dedie et `signed-by`.

## Points d'attention avant modification

- Ne pas casser le bootstrap d'un poste vierge : Git, SVN, SSH, Syncthing et Claude ont des dependances circulaires partielles.
- `syncthing-install` contient une liste de devices personnelle et lit `/home/cedric/.config/bin_ss`.
- `claude-init` depend de `~/Sync/Central/.stfolder` et de dossiers synchronises.
- `git-deploy` et `svn-deploy` ne deployent pas directement : ils alimentent `~/manuel.sh`.
- `etc-init` utilise Mercurial dans `/etc`; une migration vers etckeeper doit etre traitee comme un changement de comportement.
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
```

Le wrapper `run` applique deja un dry-run par defaut comme dans `infra-deploy`.
