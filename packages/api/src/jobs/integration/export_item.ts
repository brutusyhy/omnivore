import { IntegrationType } from '../../entity/integration'
import {
  findIntegrations,
  getIntegrationClient,
  updateIntegration,
} from '../../services/integrations'
import { findLibraryItemsByIds } from '../../services/library_item'
import { logger } from '../../utils/logger'

export interface ExportItemJobData {
  userId: string
  libraryItemIds: string[]
  integrationId?: string
}

export const EXPORT_ITEM_JOB_NAME = 'export-item'

export const exportItem = async (jobData: ExportItemJobData) => {
  const { libraryItemIds, userId, integrationId } = jobData
  const libraryItems = await findLibraryItemsByIds(libraryItemIds, userId)
  if (libraryItems.length === 0) {
    logger.error('library items not found', {
      userId,
    })
    return
  }

  const integrations = await findIntegrations(userId, {
    id: integrationId,
    enabled: true,
    type: IntegrationType.Export,
  })

  if (integrations.length <= 0) {
    return
  }

  await Promise.all(
    integrations.map(async (integration) => {
      const logObject = {
        userId,
        integrationId: integration.id,
      }
      logger.info('exporting item...', logObject)

      try {
        const client = getIntegrationClient(integration.name)

        const synced = await client.export(integration.token, libraryItems)
        if (!synced) {
          logger.error('failed to export item', logObject)
          return Promise.resolve(false)
        }

        const syncedAt = new Date()
        logger.info('updating integration...', {
          ...logObject,
          syncedAt,
        })

        // update integration syncedAt if successful
        const updated = await updateIntegration(
          integration.id,
          {
            syncedAt,
          },
          userId
        )
        logger.info('integration updated', {
          ...logObject,
          updated,
        })

        return Promise.resolve(true)
      } catch (err) {
        logger.error('export with integration failed', err)
        return Promise.resolve(false)
      }
    })
  )
}
