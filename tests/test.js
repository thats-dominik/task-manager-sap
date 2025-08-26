const cds = require('@sap/cds/lib')
const { default: axios } = require('axios')
const { GET, POST, DELETE, PATCH, expect } = cds.test(__dirname + '../../')

jest.setTimeout(15000)

/** helper to switch mocked user */
const asUser = (u) => { axios.defaults.auth = { username: u, password: 'any' } }

/** base path */
const BASE = '/odata/v4/processor'

describe('ProcessorService – chef (heiko)', () => {
  let taskId, draftId

  beforeAll(() => asUser('heiko')) // chef

  it('create Task draft', async () => {
    const { status, data } = await POST(`${BASE}/Tasks`, {
      title: 'Test Task',
      description: 'Draft creation check',
      dueDate: '2025-12-31',
      status_code: 'OPEN',
      urgency_code: 'NORMAL'
    })
    expect(status).to.equal(201)
    expect(data).to.have.property('ID')
    draftId = data.ID
  })

  it('activate draft -> active Task', async () => {
    const res = await POST(
      `${BASE}/Tasks(ID=${draftId},IsActiveEntity=false)/ProcessorService.draftActivate`
    )
    expect([200, 201]).to.include(res.status)
    expect(res.data.IsActiveEntity).to.eql(true)
    taskId = res.data.ID
  })

  it('read active Task', async () => {
    const { status, data } = await GET(`${BASE}/Tasks(ID=${taskId},IsActiveEntity=true)`)
    expect(status).to.eql(200)
    expect(data.status_code).to.eql('OPEN')
  })

  it('draftEdit active Task', async () => {
    const { status } = await POST(
      `${BASE}/Tasks(ID=${taskId},IsActiveEntity=true)/ProcessorService.draftEdit`,
      { PreserveChanges: true }
    )
    expect(status).to.equal(201)
  })

  it('patch Task draft description', async () => {
    const { status } = await PATCH(
      `${BASE}/Tasks(ID=${taskId},IsActiveEntity=false)`,
      { description: 'Updated by test' }
    )
    expect(status).to.equal(200)
  })

  it('activate edited draft', async () => {
    const res = await POST(
      `${BASE}/Tasks(ID=${taskId},IsActiveEntity=false)/ProcessorService.draftActivate`
    )
    expect([200, 201]).to.include(res.status)
    expect(res.data.description).to.eql('Updated by test')
  })

  it('add Comment to Task', async () => {
    const { status, data } = await POST(`${BASE}/Comments`, {
      task_ID: taskId,
      message: 'This is a test comment'
    })
    expect(status).to.equal(201)
    expect(data.message).to.eql('This is a test comment')
  })

  it('cleanup: delete draft (if any)', async () => {
    const res = await DELETE(`${BASE}/Tasks(ID=${taskId},IsActiveEntity=false)`)
    expect([200, 204, 404]).to.include(res.status)
  })

  it('cleanup: delete Task', async () => {
    const res = await DELETE(`${BASE}/Tasks(ID=${taskId},IsActiveEntity=true)`)
    expect([200, 204]).to.include(res.status)
  })
})

describe('ProcessorService – role restrictions (heikel/heiker)', () => {
  let taskId

  beforeAll(() => asUser('heiko')) // chef erzeugt Testdaten
  it('chef creates an active Task to use in role tests', async () => {
    const { data } = await POST(`${BASE}/Tasks`, {
      title: 'Role Check Task',
      description: 'role-tests',
      dueDate: '2025-12-31',
      status_code: 'OPEN',
      urgency_code: 'NORMAL'
    })
    const act = await POST(
      `${BASE}/Tasks(ID=${data.ID},IsActiveEntity=false)/ProcessorService.draftActivate`
    )
    taskId = act.data.ID
    expect(taskId).to.be.ok
  })

  it('praktikant: cannot CREATE Tasks (403), but can CREATE Comments (201)', async () => {
    asUser('heikel') // praktikant
    await expect(
      POST(`${BASE}/Tasks`, { title: 'x', status_code: 'OPEN', urgency_code: 'NORMAL' })
    ).to.be.rejectedWith(/403/)

    const { status } = await POST(`${BASE}/Comments`, {
      task_ID: taskId,
      message: 'praktikant comment'
    })
    expect(status).to.equal(201)
  })

  it('mitarbeiter: can CREATE Tasks (201), Comments CREATE should be 403 (read-only)', async () => {
    asUser('heiker') // mitarbeiter
    const created = await POST(`${BASE}/Tasks`, {
      title: 'Mitarbeiter Task',
      status_code: 'OPEN',
      urgency_code: 'NORMAL'
    })
    expect(created.status).to.equal(201)

    await expect(
      POST(`${BASE}/Comments`, { task_ID: taskId, message: 'mitarbeiter comment' })
    ).to.be.rejectedWith(/403/)
  })
})
