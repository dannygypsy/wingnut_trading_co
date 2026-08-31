export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    if (!id) throw createError({ statusCode: 400, message: 'Missing ID' })

    await prisma.inventory.delete({ where: { id } })

    return { success: true }
})