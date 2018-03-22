SyncSettings = require '../lib/sync-settings'
SpecHelper = require './spec-helpers'
run = SpecHelper.callAsync
fs = require 'fs'
path = require 'path'
os = require 'os'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SyncSettings", ->

  describe "low-level", ->
    describe "::fileContent", ->
      tmpPath = path.join(os.tmpdir(), 'atom-sync-settings.tmp')

      it "returns null for not existing file", ->
        expect(SyncSettings.fileContent(tmpPath)).toBeNull()

      it "returns null for empty file", ->
        fs.writeFileSync tmpPath, ""
        try
          expect(SyncSettings.fileContent(tmpPath)).toBeNull()
        finally
          fs.unlinkSync tmpPath

      it "returns content of existing file", ->
        text = "alabala portocala"
        fs.writeFileSync tmpPath, text
        try
          expect(SyncSettings.fileContent(tmpPath)).toEqual text
        finally
          fs.unlinkSync tmpPath

  describe "high-level", ->
    TOKEN_CONFIG = 'sync-settings.personalAccessToken'
    GIST_ID_CONFIG = 'sync-settings.gistId'

    window.resetTimeouts()
    SyncSettings.activate()
    window.advanceClock()

    beforeEach ->
      @token = process.env.GITHUB_TOKEN or atom.config.get(TOKEN_CONFIG)
      atom.config.set(TOKEN_CONFIG, @token)

      run (cb) ->
        gistSettings =
          public: false
          description: "Test gist by Sync Settings for Atom https://github.com/atom-community/sync-settings"
          files: README: content: '# Generated by Sync Settings for Atom https://github.com/atom-community/sync-settings'
        SyncSettings.createClient().gists.create(gistSettings, cb)
      , (err, res) =>
        expect(err).toBeNull()

        @gistId = res.id
        console.log "Using Gist #{@gistId}"
        atom.config.set(GIST_ID_CONFIG, @gistId)

    afterEach ->
      run (cb) =>
        SyncSettings.createClient().gists.delete {id: @gistId}, cb
      , (err, res) ->
        expect(err).toBeNull()

    describe "::backup", ->
      it "back up the settings", ->
        atom.config.set('sync-settings.syncSettings', true)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['settings.json']).toBeDefined()

      it "don't back up the settings", ->
        atom.config.set('sync-settings.syncSettings', false)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['settings.json']).not.toBeDefined()

      it "back up the installed packages list", ->
        atom.config.set('sync-settings.syncPackages', true)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['packages.json']).toBeDefined()

      it "don't back up the installed packages list", ->
        atom.config.set('sync-settings.syncPackages', false)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['packages.json']).not.toBeDefined()

      it "back up the user keymaps", ->
        atom.config.set('sync-settings.syncKeymap', true)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['keymap.cson']).toBeDefined()

      it "don't back up the user keymaps", ->
        atom.config.set('sync-settings.syncKeymap', false)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['keymap.cson']).not.toBeDefined()

      it "back up the user styles", ->
        atom.config.set('sync-settings.syncStyles', true)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['styles.less']).toBeDefined()

      it "don't back up the user styles", ->
        atom.config.set('sync-settings.syncStyles', false)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['styles.less']).not.toBeDefined()

      it "back up the user init script file", ->
        atom.config.set('sync-settings.syncInit', true)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files[path.basename(atom.getUserInitScriptPath())]).toBeDefined()

      it "don't back up the user init script file", ->
        atom.config.set('sync-settings.syncInit', false)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files[path.basename(atom.getUserInitScriptPath())]).not.toBeDefined()

      it "back up the user snippets", ->
        atom.config.set('sync-settings.syncSnippets', true)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['snippets.cson']).toBeDefined()

      it "don't back up the user snippets", ->
        atom.config.set('sync-settings.syncSnippets', false)
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(res.files['snippets.cson']).not.toBeDefined()

      it "back up the files defined in config.extraFiles", ->
        atom.config.set 'sync-settings.extraFiles', ['test.tmp', 'test2.tmp']
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            for file in atom.config.get 'sync-settings.extraFiles'
              expect(res.files[file]).toBeDefined()

      it "don't back up extra files defined in config.extraFiles", ->
        atom.config.set 'sync-settings.extraFiles', undefined
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) =>
            SyncSettings.createClient().gists.get({id: @gistId}, cb)
          , (err, res) ->
            expect(Object.keys(res.files).length).toBe(1)

    describe "::restore", ->
      it "updates settings", ->
        atom.config.set('sync-settings.syncSettings', true)
        atom.config.set "some-dummy", true
        run (cb) ->
          SyncSettings.backup cb
        , ->
          atom.config.set "some-dummy", false
          run (cb) ->
            SyncSettings.restore cb
          , ->
            expect(atom.config.get "some-dummy").toBeTruthy()

      it "doesn't updates settings", ->
        atom.config.set('sync-settings.syncSettings', false)
        atom.config.set "some-dummy", true
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) ->
            SyncSettings.restore cb
          , ->
            expect(atom.config.get "some-dummy").toBeTruthy()

      it "overrides keymap.cson", ->
        atom.config.set('sync-settings.syncKeymap', true)
        original = SyncSettings.fileContent(atom.keymaps.getUserKeymapPath()) ? "# keymap file (not found)"
        run (cb) ->
          SyncSettings.backup cb
        , ->
          fs.writeFileSync atom.keymaps.getUserKeymapPath(), "#{original}\n# modified by sync setting spec"
          run (cb) ->
            SyncSettings.restore cb
          , ->
            expect(SyncSettings.fileContent(atom.keymaps.getUserKeymapPath())).toEqual original
            fs.writeFileSync atom.keymaps.getUserKeymapPath(), original

      it "restores all other files in the gist as well", ->
        atom.config.set 'sync-settings.extraFiles', ['test.tmp', 'test2.tmp']
        run (cb) ->
          SyncSettings.backup cb
        , ->
          run (cb) ->
            SyncSettings.restore cb
          , ->
            for file in atom.config.get 'sync-settings.extraFiles'
              expect(fs.existsSync("#{atom.getConfigDirPath()}/#{file}")).toBe(true)
              expect(SyncSettings.fileContent("#{atom.getConfigDirPath()}/#{file}")).toBe("# #{file} (not found) ")
              fs.unlink "#{atom.getConfigDirPath()}/#{file}"

      fit "skips the restore due to invalid json", ->
        atom.config.set('sync-settings.syncSettings', true)
        atom.config.set 'sync-settings.extraFiles', ['packages.json']
        atom.config.set "some-dummy", false
        run (cb) ->
          SyncSettings.backup cb
        , ->
          atom.config.set "some-dummy", true
          atom.notifications.clear()

          run (cb) ->
            SyncSettings.restore cb
          , ->
            expect(atom.notifications.getNotifications().length).toEqual 1
            expect(atom.notifications.getNotifications()[0].getType()).toBe('error')
            # the value should not be restored
            # since the restore valid to parse the input as valid json
            expect(atom.config.get "some-dummy").toBeTruthy()

    describe "::check for update", ->

      beforeEach ->
        atom.config.unset 'sync-settings._lastBackupHash'

      it "updates last hash on backup", ->
        run (cb) ->
          SyncSettings.backup cb
        , ->
          expect(atom.config.get "sync-settings._lastBackupHash").toBeDefined()

      it "updates last hash on restore", ->
        run (cb) ->
          SyncSettings.restore cb
        , ->
          expect(atom.config.get "sync-settings._lastBackupHash").toBeDefined()

      describe "::notification", ->
        beforeEach ->
          atom.notifications.clear()

        it "displays on newer backup", ->
          run (cb) ->
            SyncSettings.checkForUpdate cb
          , ->
            expect(atom.notifications.getNotifications().length).toBe(1)
            expect(atom.notifications.getNotifications()[0].getType()).toBe('warning')

        it "ignores on up-to-date backup", ->
          run (cb) ->
            SyncSettings.backup cb
          , ->
            run (cb) ->
              atom.notifications.clear()
              SyncSettings.checkForUpdate cb
            , ->
              expect(atom.notifications.getNotifications().length).toBe(1)
              expect(atom.notifications.getNotifications()[0].getType()).toBe('success')
